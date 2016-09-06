
# 问题

malaita 的 feed 流需要对 item 进行排序，排序目的是增加用户的动作，即点赞和评论。
因而使用 LR 算法对用户点赞和评论的概率进行了预测。然而，在用户的信息流中，用户点赞或者评论的文章的比例是很低的，
这个比率在实际中小于 1%。因而这在机器学习中是典型的大海捞针问题。

一般的机器学习算法都会偏向数量占优的类，因为损失函数通常会试图最优化相关的数量，例如错误率等，
而不会将数据分布纳入到考虑范围内。在最坏的情况下，少数类的样本将会被视为多数类的异常点而被忽略，然后学习算法会
生成一个简单的分类器，并将样本分类到多数类下。

# 不平衡数据的处理方法

从不平衡数据中学习，是机器学习中一个研究了很长时间但依然没有得到明确结果的问题，那种处理方法更好，往往取决于数据。
基本的处理方法如下：

## 1 什么也不做
这在 malaita 中显然是不行的，用 lr 训练出来的点赞模型，其 AUC 在 0.7 左右，而评论模型的 AUC 更在 0.63 左右，十分不准确。

## 2 通过某些方法使数据更加平衡
### 1 对少数类进行过采样 oversampling

+ 过采样的问题：复制出来的数据会使得变量的方差比实际上更小。好处是会复制误差的数量。
+ 而欠采样会让独立变量（independent variable）的方差看起来比实际的方差更高。

### 2 对多数类进行欠采样

### 3 合成新的少数类

## 3 在算法层面上进行改进

### 1 采用异常检测框架的算法
### 2 训练时调整少数类的权重
### 3 调整决策的阀值
### 4 使用其他算法 ……

# 题外话：如何进行评估

训练不平衡数据分类器时，不能使用准确率（或者错误率）进行评估。全部预测为反例即可得到很高的准确率。
一般采用的策略是：
+ ROC 曲线
+ 准确度召回曲线 precision-recall curve 
+ Lift 曲线 或者 （利润-收益曲线 profit-gain curve）
用这些曲线对分类器的表现进行可视化。二维图提供了更加丰富的信息，如果需要单纯的数字指标，主要有以下几种：
1. AUC
2. F1-score
3. Cohen's Kappa

# 理论上的方法

## 1 Class Imbalance Redux
使用欠采样构建多个模型，然后使用 bagging 方法进行组合。
参见 [blagging.py](https://github.com/silicon-valley-data-science/learning-from-imbalanced-classes/blob/master/blagging.py)。

## 2 基于近邻的方法（Neightbor-based approach）
仔细处理分界附近的实例，方法参见[TomekLink](https://github.com/ojtwist/TomekLink)

## 3 合成新样本：SMOTE 及其衍生技术
基本思想：通过在已有的样本空间插值来创建新的少数样本。
python 有 UnbalancedDataset 包中有。
局限性：SMOTE 只能填入到已有样本的凸包中（Convex Hull）中，不能创造少数类样本域之外的新样本。

## 4 调整类的权重
如 Scikit-learn 中可以使用 class_weight 参数对类的权重进行调整。

[imbalanced-learn](http://contrib.scikit-learn.org/imbalanced-learn/api.html)

# malaita 的改进策略