
搜索的基本流程：

1. query 分析 (query 归一化，query 切词，term 重要性计算，决定使用那几个召回)
2. 多队列召回 
  - TimeQueryType 
  - WebQueryType 网页结果召回
  - NormalOrQueryType OR 语法
  — NormalSynQueryType 同义词召回
3. 队列内调权
4. rank
5. 统一调权
