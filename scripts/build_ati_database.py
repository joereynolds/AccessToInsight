#!/usr/bin/env python3
import os
import re
import html
import sqlite3
import gzip
import json

CHUNK_RE = re.compile(r"<div id='COPYRIGHTED_TEXT_CHUNK'>\s*<!-- BEGIN COPYRIGHTED TEXT CHUNK -->(.*?)<!-- #COPYRIGHTED_TEXT_CHUNK", re.DOTALL)
FALLBACK_CHUNK_RE = re.compile(r"<div id='H_content'>(.*?)<!--\s*#H_content", re.DOTALL)
BODY_RE = re.compile(r"<body[^>]*>(.*?)</body>", re.DOTALL)
META_RE = re.compile(r'\[([A-Z0-9_]+)\]=\{(.*?)\}', re.DOTALL)
TAG_RE = re.compile(r'<[^>]+>')
WS_RE = re.compile(r'\s+')
NOTES_RE = re.compile(r'<div class=[\'\"]notes[\'\"]>(.*?)</div>', re.DOTALL)
NOTE_ITEM_RE = re.compile(r'<dt[^>]*>.*?(\d+).*?</dt>\s*<dd>(.*?)</dd>', re.DOTALL)

def clean_html_entities(text: str) -> str:
    if not text:
        return ""
    return html.unescape(text)

def html_to_plain(html_str: str) -> str:
    text = TAG_RE.sub(' ', html_str)
    text = html.unescape(text)
    return WS_RE.sub(' ', text).strip()

def extract_footnotes(file_text: str) -> dict:
    notes_m = NOTES_RE.search(file_text)
    if not notes_m:
        return {}
    items = NOTE_ITEM_RE.findall(notes_m.group(1))
    notes = {}
    for num, body in items:
        clean_b = html_to_plain(body)
        notes[str(int(num))] = clean_b
    return notes

def determine_collection_and_nikaya(rel_path: str, meta: dict):
    nikaya = meta.get('NIKAYA', '').strip()
    abbrev = meta.get('NIKAYA_ABBREV', '').strip()
    c_type = meta.get('TYPE', '').strip().lower()
    
    parts = rel_path.split('/')
    top = parts[0]
    
    collection = "other"
    if top == 'tipitaka':
        if len(parts) > 1:
            sub = parts[1]
            if sub == 'dn':
                collection = 'dn'
                if not nikaya: nikaya = 'Digha Nikaya'
                if not abbrev: abbrev = 'DN'
            elif sub == 'mn':
                collection = 'mn'
                if not nikaya: nikaya = 'Majjhima Nikaya'
                if not abbrev: abbrev = 'MN'
            elif sub == 'sn':
                collection = 'sn'
                if not nikaya: nikaya = 'Samyutta Nikaya'
                if not abbrev: abbrev = 'SN'
            elif sub == 'an':
                collection = 'an'
                if not nikaya: nikaya = 'Anguttara Nikaya'
                if not abbrev: abbrev = 'AN'
            elif sub == 'kn':
                collection = 'kn'
                if not nikaya: nikaya = 'Khuddaka Nikaya'
                if not abbrev: abbrev = 'KN'
                if len(parts) > 2:
                    collection = f"kn/{parts[2]}"
            elif sub == 'vin':
                collection = 'vinaya'
                if not nikaya: nikaya = 'Vinaya Pitaka'
                if not abbrev: abbrev = 'Vin'
            elif sub == 'abhi':
                collection = 'abhidhamma'
                if not nikaya: nikaya = 'Abhidhamma Pitaka'
                if not abbrev: abbrev = 'Abhi'
    elif top == 'lib':
        if len(parts) > 1:
            sub = parts[1]
            if sub == 'authors':
                author_slug = parts[2] if len(parts) > 2 else ''
                collection = f"authors/{author_slug}" if author_slug else 'authors'
                if not nikaya: nikaya = 'Library: Authors'
                if not abbrev: abbrev = 'Lib:Auth'
            elif sub == 'thai':
                thai_slug = parts[2] if len(parts) > 2 else ''
                collection = f"thai/{thai_slug}" if thai_slug else 'thai'
                if not nikaya: nikaya = 'Thai Forest Tradition'
                if not abbrev: abbrev = 'Thai'
            elif sub == 'study':
                collection = 'study'
                if not nikaya: nikaya = 'Study Guides'
                if not abbrev: abbrev = 'Study'
            else:
                collection = 'library'
                if not nikaya: nikaya = 'Library'
                if not abbrev: abbrev = 'Lib'
    elif top == 'ptf':
        collection = 'ptf'
        if not nikaya: nikaya = 'Path to Freedom'
        if not abbrev: abbrev = 'PTF'
    elif rel_path in ['theravada.html', 'befriending.html', 'begin.html', 'history.html']:
        collection = 'beginnings'
        if not nikaya: nikaya = 'Beginnings'
        if not abbrev: abbrev = 'Begin'
    
    if not c_type:
        if 'sutta' in rel_path or top == 'tipitaka':
            c_type = 'sutta'
        elif top == 'lib':
            c_type = 'article'
        elif top == 'ptf':
            c_type = 'guide'
        else:
            c_type = 'general'
            
    return collection, nikaya, abbrev, c_type

def clean_content_chunk(raw_chunk: str) -> str:
    raw = re.sub(r"<div class='alphalist'>.*?</div>", "", raw_chunk, flags=re.DOTALL)
    raw = re.sub(r"<script.*?>.*?</script>", "", raw, flags=re.DOTALL)
    return raw.strip()

def build_database(repo_root: str, out_db_path: str):
    print(f"Building SQLite database from {repo_root} -> {out_db_path}...")
    if os.path.exists(out_db_path):
        os.remove(out_db_path)
        
    conn = sqlite3.connect(out_db_path)
    cur = conn.cursor()
    
    cur.execute("PRAGMA journal_mode = WAL;")
    cur.execute("PRAGMA synchronous = NORMAL;")
    
    cur.execute("""
    CREATE TABLE texts (
        rowid INTEGER PRIMARY KEY AUTOINCREMENT,
        id TEXT UNIQUE,
        path TEXT UNIQUE,
        title TEXT NOT NULL,
        subtitle TEXT,
        sutta_ref TEXT,
        nikaya TEXT,
        nikaya_abbrev TEXT,
        collection TEXT,
        author TEXT,
        author_short TEXT,
        pts_id TEXT,
        type TEXT,
        summary TEXT,
        content_html TEXT,
        content_plain TEXT,
        footnotes_json TEXT,
        word_count INTEGER,
        year TEXT,
        license TEXT
    );
    """)
    
    cur.execute("CREATE INDEX idx_texts_nikaya ON texts(nikaya_abbrev);")
    cur.execute("CREATE INDEX idx_texts_collection ON texts(collection);")
    cur.execute("CREATE INDEX idx_texts_author ON texts(author_short);")
    cur.execute("CREATE INDEX idx_texts_sutta_ref ON texts(sutta_ref);")
    cur.execute("CREATE INDEX idx_texts_type ON texts(type);")
    
    # External content table for FTS5 (does not duplicate content_plain)
    cur.execute("""
    CREATE VIRTUAL TABLE search_index USING fts5(
        title,
        subtitle,
        sutta_ref,
        author,
        summary,
        content_plain,
        content='texts',
        content_rowid='rowid',
        tokenize = 'unicode61 remove_diacritics 2'
    );
    """)
    
    cur.execute("""
    CREATE TABLE glossary (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        term TEXT NOT NULL,
        pali_term TEXT NOT NULL,
        definition TEXT NOT NULL,
        more_path TEXT
    );
    """)
    cur.execute("CREATE INDEX idx_glossary_term ON glossary(term);")
    cur.execute("CREATE INDEX idx_glossary_pali ON glossary(pali_term);")
    
    cur.execute("""
    CREATE TABLE similes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        simile TEXT NOT NULL,
        meaning TEXT NOT NULL,
        sutta_ref TEXT,
        link_path TEXT
    );
    """)
    cur.execute("CREATE INDEX idx_similes_simile ON similes(simile);")
    
    cur.execute("""
    CREATE TABLE subjects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subject TEXT NOT NULL,
        details TEXT NOT NULL
    );
    """)
    cur.execute("CREATE INDEX idx_subjects_subject ON subjects(subject);")
    
    cur.execute("""
    CREATE TABLE dhammapada_verses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        chapter_num INTEGER,
        chapter_title TEXT,
        verse_num INTEGER,
        verse_text TEXT,
        translator TEXT
    );
    """)
    cur.execute("CREATE INDEX idx_dhp_verse_num ON dhammapada_verses(verse_num);")
    cur.execute("CREATE INDEX idx_dhp_chap ON dhammapada_verses(chapter_num);")
    
    cur.execute("""
    CREATE TABLE ptf_sections (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        step_order INTEGER,
        code TEXT UNIQUE,
        title TEXT,
        pali_name TEXT,
        summary TEXT,
        detail_path TEXT
    );
    """)

    cur.execute("""
    CREATE TABLE bookmarks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text_id TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        note TEXT
    );
    """)

    cur.execute("""
    CREATE TABLE reading_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text_id TEXT UNIQUE NOT NULL,
        progress REAL DEFAULT 0.0,
        last_read_at INTEGER NOT NULL
    );
    """)

    cur.execute("""
    CREATE TABLE daily_contemplations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        day_of_year INTEGER UNIQUE,
        title TEXT,
        verse_pali TEXT,
        verse_english TEXT,
        source_ref TEXT,
        theme TEXT,
        reflection_prompt TEXT
    );
    """)

    # 1. Walk and index all HTML files
    excluded_dirs = {'.git', 'app', 'tech', 'css', 'js', 'img', 'news', 'scripts'}
    excluded_files = {'404.html', 'search_results.html', 'random-article.html', 'random-sutta.html', 
                      'random-article-nojs.html', 'random-sutta-nojs.html', 'repackaged-example-01.html'}
    
    text_count = 0
    
    for root, dirs, files in os.walk(repo_root):
        dirs[:] = [d for d in dirs if d not in excluded_dirs]
        for f in files:
            if not f.endswith('.html') or f in excluded_files:
                continue
            
            full_path = os.path.join(root, f)
            rel_path = os.path.relpath(full_path, repo_root)
            
            with open(full_path, 'r', encoding='utf-8', errors='ignore') as fp:
                file_text = fp.read()
                
            m_chunk = CHUNK_RE.search(file_text)
            if not m_chunk:
                m_chunk = FALLBACK_CHUNK_RE.search(file_text)
            if not m_chunk and '<!-- Begin ATIDoc metadata dump:' in file_text:
                m_chunk = BODY_RE.search(file_text)
                
            if not m_chunk:
                continue
                
            content_html = clean_content_chunk(m_chunk.group(1))
            if not content_html:
                continue
                
            meta = dict(META_RE.findall(file_text))
            
            title = meta.get('MY_TITLE', '').strip()
            if not title:
                t_match = re.search(r'<title>(.*?)</title>', file_text, re.IGNORECASE)
                title = t_match.group(1) if t_match else f.replace('.html', '')
            title = clean_html_entities(title)
            
            subtitle = clean_html_entities(meta.get('SUBTITLE', '').strip())
            author = clean_html_entities(meta.get('AUTHOR', '').strip())
            author_short = clean_html_entities(meta.get('AUTHOR_SHORTNAME', '').strip())
            pts_id = clean_html_entities(meta.get('PTS_ID', '').strip())
            summary = clean_html_entities(meta.get('SUMMARY', '').strip())
            year = meta.get('ATI_YEAR', meta.get('SOURCE_COPYRIGHT_YEAR', '')).strip()
            license_val = meta.get('LICENSE', '').strip()
            
            collection, nikaya, abbrev, c_type = determine_collection_and_nikaya(rel_path, meta)
            
            sutta_num = meta.get('NUMBER', '').strip()
            sutta_ref = ""
            if abbrev and sutta_num:
                sutta_ref = f"{abbrev} {sutta_num}"
            elif abbrev in ['DN', 'MN', 'SN', 'AN', 'Khp', 'Dhp', 'Ud', 'Iti', 'Sn', 'Vv', 'Pv', 'Thag', 'Thig']:
                fn_parts = f.split('.')
                if len(fn_parts) >= 3 and fn_parts[1].isdigit():
                    sutta_ref = f"{abbrev} {fn_parts[1]}"
                    sutta_num = fn_parts[1]
                elif len(fn_parts) >= 4 and fn_parts[0].upper() == abbrev:
                    sutta_ref = f"{abbrev} {fn_parts[1]}"
                    sutta_num = fn_parts[1]
            
            plain = html_to_plain(content_html)
            words = len(plain.split())
            doc_id = rel_path
            
            footnotes = extract_footnotes(file_text)
            fn_json = json.dumps(footnotes) if footnotes else "{}"
            
            cur.execute("""
            INSERT OR REPLACE INTO texts (
                id, path, title, subtitle, sutta_ref, nikaya, nikaya_abbrev,
                collection, author, author_short, pts_id, type, summary,
                content_html, content_plain, footnotes_json, word_count, year, license
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, (
                doc_id, rel_path, title, subtitle, sutta_ref, nikaya, abbrev,
                collection, author, author_short, pts_id, c_type, summary,
                content_html, plain, fn_json, words, year, license_val
            ))
            
            row_id = cur.lastrowid
            cur.execute("""
            INSERT INTO search_index (rowid, title, subtitle, sutta_ref, author, summary, content_plain)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """, (
                row_id, title, subtitle, sutta_ref, author, summary, plain
            ))
            
            text_count += 1

    print(f"Indexed {text_count} texts.")

    # 2. Extract Glossary
    glossary_path = os.path.join(repo_root, 'glossary.html')
    if os.path.exists(glossary_path):
        with open(glossary_path, 'r', encoding='utf-8', errors='ignore') as fp:
            g_txt = fp.read()
        g_items = re.findall(r'<dt>(.*?)</dt>\s*<dd>(.*?)</dd>', g_txt, re.DOTALL)
        g_count = 0
        for dt_str, dd_str in g_items:
            t_clean = html.unescape(TAG_RE.sub('', dt_str)).strip().rstrip(':')
            pali_clean = t_clean
            more_m = re.search(r'href=[\'\"]([^\'\"]+)[\'\"]>MORE</a>', dd_str, re.IGNORECASE)
            more_path = more_m.group(1) if more_m else ''
            
            dd_clean = html.unescape(TAG_RE.sub('', dd_str)).strip()
            dd_clean = re.sub(r'\[MORE\]', '', dd_clean).strip()
            
            cur.execute("INSERT INTO glossary (term, pali_term, definition, more_path) VALUES (?, ?, ?, ?)",
                        (t_clean.lower(), pali_clean, dd_clean, more_path))
            g_count += 1
        print(f"Indexed {g_count} glossary terms.")

    # 3. Extract Similes
    similes_path = os.path.join(repo_root, 'index-similes.html')
    if os.path.exists(similes_path):
        with open(similes_path, 'r', encoding='utf-8', errors='ignore') as fp:
            s_txt = fp.read()
        s_items = re.findall(r'<dt>(.*?)</dt>\s*<dd>(.*?)</dd>', s_txt, re.DOTALL)
        s_count = 0
        for dt_str, dd_str in s_items:
            s_name = html.unescape(TAG_RE.sub('', dt_str)).strip().rstrip(':')
            s_body = html.unescape(TAG_RE.sub('', dd_str)).strip()
            link_m = re.search(r'href=[\'\"]([^\'\"]+)[\'\"]', dd_str)
            link_path = link_m.group(1) if link_m else ''
            
            meaning_m = re.search(r'\{(.*?)\}', s_body)
            meaning = meaning_m.group(1) if meaning_m else s_body
            
            cur.execute("INSERT INTO similes (simile, meaning, sutta_ref, link_path) VALUES (?, ?, ?, ?)",
                        (s_name, meaning, s_body, link_path))
            s_count += 1
        print(f"Indexed {s_count} similes.")

    # 4. Extract Subjects
    subject_path = os.path.join(repo_root, 'index-subject.html')
    if os.path.exists(subject_path):
        with open(subject_path, 'r', encoding='utf-8', errors='ignore') as fp:
            sub_txt = fp.read()
        sub_items = re.findall(r'<dt>(.*?)</dt>\s*<dd>(.*?)</dd>', sub_txt, re.DOTALL)
        sub_count = 0
        for dt_str, dd_str in sub_items:
            sub_name = html.unescape(TAG_RE.sub('', dt_str)).strip().rstrip(':')
            sub_body = html.unescape(TAG_RE.sub('', dd_str)).strip()
            cur.execute("INSERT INTO subjects (subject, details) VALUES (?, ?)", (sub_name, sub_body))
            sub_count += 1
        print(f"Indexed {sub_count} subject entries.")

    # 5. Extract Dhammapada verses
    dhp_dir = os.path.join(repo_root, 'tipitaka/kn/dhp')
    if os.path.exists(dhp_dir):
        dhp_files = sorted([f for f in os.listdir(dhp_dir) if f.startswith('dhp.') and f.endswith('.than.html') and f != 'dhp.intro.than.html'])
        verse_count = 0
        for df in dhp_files:
            chap_num = int(df.split('.')[1])
            with open(os.path.join(dhp_dir, df), 'r', encoding='utf-8', errors='ignore') as fp:
                d_content = fp.read()
            t_m = re.search(r'<div id="H_docTitle">(.*?)</div>', d_content)
            chap_title = html.unescape(t_m.group(1).strip()) if t_m else f"Chapter {chap_num}"
            
            v_matches = re.finditer(r'<h5><a[^>]*id=[\'\"]dhp-(\d+)[\'\"][^>]*>([^<]+)</a></h5>\s*<div class=[\'\"]freeverse[\'\"]>(.*?)</div>', d_content, re.DOTALL)
            for vm in v_matches:
                v_start = int(vm.group(1))
                v_label = vm.group(2).strip()
                v_text = html_to_plain(vm.group(3))
                cur.execute("""
                INSERT INTO dhammapada_verses (chapter_num, chapter_title, verse_num, verse_text, translator)
                VALUES (?, ?, ?, ?, ?)
                """, (chap_num, chap_title, v_start, f"[{v_label}] {v_text}", "Thanissaro Bhikkhu"))
                verse_count += 1
        print(f"Indexed {verse_count} Dhammapada verse groups.")

    # 6. Seed Path to Freedom (PTF) Gradual Training Structure
    ptf_steps = [
        (1, "dana", "Dāna: Generosity", "dāna", "The practice of giving freely, abandoning stinginess, and opening the heart to others. The natural foundation for spiritual growth.", "ptf/dhamma/dana/index.html"),
        (2, "sila", "Sīla: Virtue & Moral Harmony", "sīla", "The Five Precepts: living without harming, theft, sexual misconduct, lying, or intoxicants. Cultivating self-respect and fearlessness.", "ptf/dhamma/sila/index.html"),
        (3, "sagga", "Sagga: The Heavens & Karmic Fruits", "sagga", "Understanding how actions have consequences in the mind and across the cosmos. The uplifting results of goodness.", "ptf/dhamma/sagga/index.html"),
        (4, "adinava", "Ādīnava: The Drawbacks of Sensuality", "ādīnava", "Recognizing the inherent danger, insatiability, and stress of clinging to sensory pleasures and worldly fortunes.", "ptf/dhamma/adinava/index.html"),
        (5, "nekkhamma", "Nekkhamma: Renunciation", "nekkhamma", "The bliss of blamelessness and letting go. Stepping out of worldly entanglement into inner peace and meditation.", "ptf/dhamma/nekkhamma/index.html"),
        (6, "sacca", "Sacca: The Four Noble Truths", "ariya-sacca", "The culmination of wisdom: Dukkha (Stress), Samudaya (Origin: Craving), Nirodha (Cessation: Nibbana), and Magga (The Noble Eightfold Path).", "ptf/dhamma/sacca/index.html")
    ]
    for step in ptf_steps:
        cur.execute("""
        INSERT INTO ptf_sections (step_order, code, title, pali_name, summary, detail_path)
        VALUES (?, ?, ?, ?, ?, ?)
        """, step)
    print("Indexed Path to Freedom gradual training stages.")

    # 7. Seed Daily Contemplations
    daily_seeds = [
        (1, "The Mind Leads All Things", "Manopubbaṅgamā dhammā manosettha manomayā", "Phenomena are preceded by the heart, ruled by the heart, made of the heart. If you speak or act with a calm heart, happiness follows you like a shadow that never leaves.", "Dhp 1-2", "Mindfulness of Intention", "Observe the underlying intention behind your actions and words throughout the day. Cultivate clarity before speaking."),
        (2, "Heedfulness is the Deathless", "Appamādo amatapadaṁ pamādo maccuno padaṁ", "Heedfulness is the path to the Deathless; heedlessness is the path to death. Those who are heedful do not die; those who are heedless are as if already dead.", "Dhp 21", "Heedfulness (Appamada)", "Notice moments when the mind drifts into autopilot or complacency. Gently anchor awareness back to this present moment."),
        (3, "Training the Untrained Mind", "Dunniggahassa lahuno yatthakāmanipātino", "Wonderful it is to tame the mind, which is so difficult to subdue, so swift, and which flies wherever it pleases. A tamed mind brings true peace.", "Dhp 35", "Mind Training", "Do not judge a restless mind; gently acknowledge its wandering nature, and bring attention back to the breath."),
        (4, "Conquering Anger with Loving-Kindness", "Akkodhena jine kodhaṁ asādhuṁ sādhunā jine", "Conquer anger with non-anger. Conquer wickedness with goodness. Conquer the stingy with giving, and a liar with the truth.", "Dhp 223", "Goodwill & Patience", "When someone provokes irritation today, pause before reacting. Offer quiet compassion in your mind."),
        (5, "The Non-Self Nature", "Sabbe dhammā anattāti yadā paññāya passati", "When one sees with wisdom that all phenomena are not-self, one turns away from suffering. This is the path of purity.", "Dhp 279", "Wisdom (Paññā)", "Reflect on thoughts, feelings, and bodily sensations as transient visitors rather than 'mine' or 'who I am'."),
        (6, "The Gift of Dhamma", "Sabbadānaṁ dhammadānaṁ jināti", "The gift of Dhamma excels all gifts; the taste of Dhamma excels all tastes; the delight in Dhamma excels all delights; the ending of craving conquers all suffering.", "Dhp 354", "Generosity of Spirit", "Share patience, understanding, and peaceful presence freely with everyone you encounter today."),
        (7, "The Silent Island", "Dīpaṁ karotha attānaṁ khippaṁ vāyama paṇḍito", "Make an island of yourself; strive swiftly, become wise! Purged of blemishes and free from stain, you will reach the noble plane.", "Dhp 236", "Inner Refuge", "Amid outer noise and endless worldly demands, take refuge in the quiet stillness inside yourself.")
    ]
    for cs in daily_seeds:
        cur.execute("""
        INSERT INTO daily_contemplations (day_of_year, title, verse_pali, verse_english, source_ref, theme, reflection_prompt)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        """, cs)
    print("Indexed Daily Contemplations.")

    conn.commit()
    cur.execute("PRAGMA optimize;")
    conn.close()
    
    db_size = os.path.getsize(out_db_path)
    print(f"Database built successfully! Size: {db_size / (1024*1024):.2f} MB")
    
    gz_path = out_db_path + ".gz"
    print(f"Compressing into {gz_path}...")
    with open(out_db_path, 'rb') as f_in:
        with gzip.open(gz_path, 'wb', compresslevel=9) as f_out:
            f_out.writelines(f_in)
    gz_size = os.path.getsize(gz_path)
    print(f"Gzipped database size: {gz_size / (1024*1024):.2f} MB")

if __name__ == '__main__':
    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
    out_dir = os.path.join(repo_root, 'app/assets')
    os.makedirs(out_dir, exist_ok=True)
    out_db = os.path.join(out_dir, 'ati_data.db')
    build_database(repo_root, out_db)
