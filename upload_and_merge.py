import json
import os
import re
import subprocess
import sys
import yaml

def get_latest_remote_file(repo_path, file_name):
    """从远程仓库拉取最新的文件内容"""
    try:
        subprocess.run(['git', 'pull', 'origin', 'main'], cwd=repo_path, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error pulling from remote: {e}")
        return None
    
    file_path = os.path.join(repo_path, file_name)
    if not os.path.exists(file_path):
        return None
        
    with open(file_path, 'r', encoding='utf-8') as f:
        return f.read()

def merge_clash_configs(existing_content, new_content):
    """合并 Clash 配置文件，会保留并添加新节点"""
    try:
        existing_data = yaml.safe_load(existing_content)
        new_data = yaml.safe_load(new_content)
    except yaml.YAMLError as e:
        print(f"Error parsing YAML: {e}")
        return None

    if not existing_data or not new_data:
        return None
    
    existing_proxies = {p['name']: p for p in existing_data.get('proxies', [])}
    new_proxies = {p['name']: p for p in new_data.get('proxies', [])}

    merged_proxies = {**existing_proxies, **new_proxies}
    existing_data['proxies'] = list(merged_proxies.values())
    
    if 'proxy-groups' in existing_data:
        for group in existing_data['proxy-groups']:
            if group['type'] == 'select' and 'proxies' in group:
                for proxy_name in new_proxies:
                    if proxy_name not in group['proxies']:
                        group['proxies'].append(proxy_name)
    
    return yaml.dump(existing_data, sort_keys=False, allow_unicode=True)

def merge_singbox_configs(existing_content, new_content):
    """合并 Sing-box 配置文件，会保留并添加新节点"""
    try:
        existing_data = json.loads(existing_content)
        new_data = json.loads(new_content)
    except json.JSONDecodeError as e:
        print(f"Error parsing JSON: {e}")
        return None
        
    if not existing_data or not new_data:
        return None

    existing_outbounds = {o['tag']: o for o in existing_data.get('outbounds', [])}
    new_outbounds = {o['tag']: o for o in new_data.get('outbounds', [])}
    
    merged_outbounds = {**existing_outbounds, **new_outbounds}
    existing_data['outbounds'] = list(merged_outbounds.values())
    
    return json.dumps(existing_data, indent=2, ensure_ascii=False)

def merge_txt_files(existing_content, new_content):
    """合并 TXT 文件，添加新行"""
    existing_lines = set(existing_content.strip().split('\n'))
    new_lines = set(new_content.strip().split('\n'))
    
    merged_lines = existing_lines.union(new_lines)
    return '\n'.join(sorted(list(merged_lines)))

def main():
    if len(sys.argv) < 4:
        print("Usage: python3 upload_and_merge.py <file_path> <repo_path> <file_type>")
        sys.exit(1)
        
    file_path = sys.argv[1]
    repo_path = sys.argv[2]
    file_type = sys.argv[3]
    
    if not os.path.exists(file_path):
        print(f"Error: Source file not found at {file_path}")
        sys.exit(1)

    file_name = f'sing_box_client.json' if file_type == 'singbox' else f'clash_meta_client.yaml' if file_type == 'clash' else 'jh_sub.txt'
    
    with open(file_path, 'r', encoding='utf-8') as f:
        new_content = f.read()
        
    existing_content = get_latest_remote_file(repo_path, file_name)

    if not existing_content:
        merged_content = new_content
    else:
        if file_type == 'clash':
            merged_content = merge_clash_configs(existing_content, new_content)
        elif file_type == 'singbox':
            merged_content = merge_singbox_configs(existing_content, new_content)
        elif file_type == 'jh':
            merged_content = merge_txt_files(existing_content, new_content)
        else:
            print(f"Unsupported file type: {file_type}")
            sys.exit(1)
            
    if merged_content is None:
        print("Failed to merge files.")
        sys.exit(1)

    merged_file_path = os.path.join(repo_path, file_name)
    with open(merged_file_path, 'w', encoding='utf-8') as f:
        f.write(merged_content)
        
    print(f"File {file_name} has been merged and saved.")

if __name__ == "__main__":
    main()
