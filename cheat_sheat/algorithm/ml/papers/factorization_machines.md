因子分解学习机
-----

[Factorization Machine](https://www.ismll.uni-hildesheim.de/pub/pdfs/Rendle2010FM.pdf)

## Abstract
+ `FM` 和 `SVM` 有什么相同和不同之处？带来了什么优点和缺点？
    - 组合了 `Factorization model` 和 `SVM` 的优点
    - 使用 `factorized` 参数来对变量之间的关系进行建模，因而可以解决大规模稀疏问题 (如推荐系统)
    - 和 `SVM` 不同，不需要进行对偶转换
    - `FM` 的原始问题可以在线性的时间内进行计算，因而可以直接进行优化，可以扩展到巨大的数据集上去
    - 
+ `FM` 和其他 `Factorization model` 的区别
    - `SVD++`、`PITF`、`FPMC` 等仅能在特殊的输入数据上工作，不能应用在所有的预测任务上。
    - `SVD++`、`PITF`、`FPMC` 等方法的 equation、优化算法和特定的任务有关系。
    - 通过输入数据的修改（`defining the feature vectors of the input data`)，`FM` 可以模拟这些方法。
    - 不需要专业的知识就可以使用 `FM`
