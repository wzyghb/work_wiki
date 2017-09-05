# 推荐系统算法总结

1. 推荐系统整体框架有哪些部分？
1. 推荐系统线上实用的模型有哪些？
    1. 比如常用的模型有 LR、FM、DNN，是否都对线上性能有帮助
    1. 用了 DNN 之后，“浅模型 + 特征工程” 是否还有必要？
    1. 常见的工业界推荐系统很多都采用 逐层减少候选，最后使用一个精排模型，这种设计的核心是什么？是否有其他选择？
1. 目前推荐系统的瓶颈是什么？
+ 是速度？准确性？还是别的？
1. 技术角度和产品角度考虑问题出现冲突后如何解决？

## 主题：LDA，文章间的相似度使用主题分布的 Jenson-Shannon Divergence (JSD) 相似度来近似。

+ 用户特征：用户阅读过的文章、动作类型和动作时间
+ 文章特征：与该文章相似的文章及其相似度

主题模型是基于内容的推荐策略，冷启动效果好。但是内容容易收敛，

## 城市

## 主题词

通过分析用户阅读过的文章，获取用户对于各个主题词的偏好。

+ 用户特征: 用户阅读过的文章中计算 tf * idf, 保留 1500 个主题词
+ 文章特征：主题词及其权重

可解释性好。但是准确率低，在线推荐计算量比较大。

## 热门

## Friend

## 长期兴趣主题词

## 相似用户阅读列表

## 关联文章

## 协同过滤

## 站内热门

## LR

## 基本算法

### GDBT [Gradient Decision Boosting Tree](https://en.wikipedia.org/wiki/Gradient_boosting)

#### 概述

既可以用于回归也可以用于分类。

+ 优点：
  + 天生可以处理混合类型的数据 (异构特征)
  + 预测能力很强
  + 对输出空间的奇异点有很强的鲁棒性
+ 缺点
  + 扩展性，由于 boosting 的自然有序特性，很难进行并行化

#### 算法实现

> `Fm+1(x) = Fm(x) + h(x) = y`
> `h(x) = y - Fm(x)`
> `F(x) = SUM(1~m)(gama_i * h_i(x)) + const`
> 典型实现： `Gradient Boosting Decision Tree` 树的节点一般都在 4 ~ 8 之间

#### 正则化

+ Shrinkage：Fm(x) = Fm-1(x) + v*rm*hm(x) 增加一个正则参数
+ Stochastic Gradient Boosting 随机选择一些训练样例进行训练，通常选择 0.5 —— 0.8 左右的训练样例进行训练。
+ Number of observations in leaves: 限制每个节点上观测者的最小数量来减小方差
+ Penalize Complexity of Tree: 对树的复杂性进行惩罚

### FM [Factorization Machine](https://www.ismll.uni-hildesheim.de/pub/pdfs/Rendle2010FM.pdf)

+ FMs 可以在非常稀疏的数据下估计参数，而此时 SVM 会失败。
+ FMs 本身具有线性的复杂度，不会受到支持向量的影响，如 SVM。可以扩展到 10 亿的 Netflix 训练样例上。
+ FMs 是通用的预测器，可以在任意实数值的特征向量上使用。
+ FFM   (Field-aware Factorization Machines)
+ LR    (Logistic regression)

## 推荐特征

## user

+ 用户的语言
+ 用户的区域
+ device_platform 设备平台
+ traffic_type 网络环境
+ crg 用户注册区域
+ reg 用户注册时间
+ 用户的时区

## item

+ impression 数 （展示的数量）
+ 文章来源的级别 （对于权威的网站，如 wiki，可以设置一个比较高的值）
+ 文章的评论数
+ 视频的大图
+ 文章点击数
+ 视频的播放量
+ 站外热度
+ 文章的创建时间
+ 文章创建时间
+ 文章类型
+ 召回策略
+ 召回分数
