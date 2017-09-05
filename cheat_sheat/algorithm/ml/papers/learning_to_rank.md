# 学习排序

感觉这部分还有很多需要了解。

## Start

1. 机器学习问题，通过训练数据构建排序模型。
1. 训练数据可以是 partial order 的，或者 binary judgement
1. 学习排序时 personalization 的核心。
1. 通常是一个 supervised classification 问题。

## Metrics

1. Normalized Discounted Cumulative Gain
1. Mean Reciprocal Rank (MRR)
1. Fraction of Concordant Pair

## Aproaches

1. Pointwire
    1. minimizes loss function defined on individual relevance judgment
    1. ranking score based on regeression or classification
    1. Ordinal regression, Logistic Regression, SVM, GBDT
1. Pairwise
    1. LOss function is defined on pair-wise preference
    1. Goal: minimise number of inversions in rank
    1. transformed to binary classification problem
    1. LambdaMark, RankSVM, RankBoost, RankNet, FRank
1. Listwise
    1. Indirect Loss Function
        1. RankCosine
        1. ListNet
    1. Directly optimizing IR measures
        1. 遗传算法、模拟降火
        1. Gradient descent on smoothed version of objective function (CLiMF, TFMAP)
        1. SVM-MAP relaxed MAP metric by adding to SVM constraint
        1. AdaRank uses boosting to optimize NDCG

待补充
