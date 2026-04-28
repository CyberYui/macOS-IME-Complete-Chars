# 导入依赖库（需先安装pandas，执行命令：pip install pandas）
import pandas as pd
import json

# 第一步：读取权威字表数据（JSON和CSV文件，路径为当前文件夹，即~/Documents/MacIME_Project/）
def read_data():
    # 读取JSON文件（新华字典数据）
    with open('data/chinese-xinhua.json', 'r', encoding='utf-8') as f:
        json_data = json.load(f)
    # 读取CSV文件（拼音数据）
    csv_data = pd.read_csv('pinyin-data.csv', encoding='utf-8')
    return json_data, csv_data

# 第二步：筛选缺失字（因Mac自定义短语为空，所有权威字表中的偏旁、生僻字均为缺失字）
def filter_missing_chars(json_data):
    # 分离偏旁和生僻字
    radicals = []  # 缺失偏旁
    chars = []     # 缺失生僻字
    for item in json_data:
        if item['类型'] == '偏旁':
            radicals.append({'字': item['字'], '拼音': item['拼音']})
        elif item['类型'] == '生僻字':
            chars.append({'字': item['字'], '拼音': item['拼音']})
    return radicals, chars

# 第三步：生成CSV文件（missing-radicals.csv 和 missing-chars.csv）
def generate_csv(radicals, chars):
    # 生成偏旁CSV
    radicals_df = pd.DataFrame(radicals)
    radicals_df.to_csv('missing-radicals.csv', index=False, encoding='utf-8')
    # 生成生僻字CSV
    chars_df = pd.DataFrame(chars)
    chars_df.to_csv('missing-chars.csv', index=False, encoding='utf-8')
    print("CSV文件生成完成：missing-radicals.csv（偏旁）、missing-chars.csv（生僻字）")

# 主函数（执行整个筛选流程）
if __name__ == "__main__":
    # 读取数据
    json_data, csv_data = read_data()
    # 筛选缺失字（跳过原生单字对比，因自定义短语为空）
    radicals, chars = filter_missing_chars(json_data)
    # 生成CSV文件
    generate_csv(radicals, chars)
    print("数据筛选完成，可用于生成plist文件")