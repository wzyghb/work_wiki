# 搜索总结

搜索的基本流程

1. query 分析 (query 归一化，query 切词，term 重要性计算，决定使用那几个召回)
1. 多队列召回
    1. TimeQueryType
    1. WebQueryType 网页结果召回
    1. NormalOrQueryType OR 语法
    1. NormalSynQueryType 同义词召回
1. 队列内调权
1. rank
1. 统一调权


# 分词器

+ [ref: sego](https://github.com/huichen/sego)
