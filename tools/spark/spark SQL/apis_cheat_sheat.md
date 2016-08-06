
```
wordsDF = sqlContext.createDataFrame([('cat',), ('elephant',), ('rat',), ('rat',), ('cat', )], ['word'])
wordsDF.show()
wordsDF.printSchema()

from pyspark.sql.functions import lit, concat, length
pluralDF = wordsDF.select(concat(wordsDF.word, lit('s')).alias('word'))
pluralLengthsDF = pluralDF.select(length(pluralDF.word))

wordCountsDF = (wordsDF
                .groupBy(wordsDF.word)
                .count())

uniqueWordsCount = wordsDF.distinct().count()

averageCount = (wordCountsDF
                .groupBy()
                .mean()
                .collect()[0].asDict().values()[0])

from pyspark.sql.functions import regexp_replace, trim, col, lower
def removePunctuation(column):
    """Removes punctuation, changes to lower case, and strips leading and trailing spaces.

    Note:
        Only spaces, letters, and numbers should be retained.  Other characters should should be
        eliminated (e.g. it's becomes its).  Leading and trailing spaces should be removed after
        punctuation is removed.

    Args:
        column (Column): A Column containing a sentence.

    Returns:
        Column: A Column named 'sentence' with clean-up operations applied.
    """
    import re
    return regexp_replace(lower(trim(column)), "[^\w| ]", "").alias("sentence")

sentenceDF = sqlContext.createDataFrame([('Hi, you!',),
                                         (' No under_score!',),
                                         (' *      Remove punctuation then spaces  * ',)], ['sentence'])
sentenceDF.show(truncate=False)
(sentenceDF
 .select(removePunctuation(col('sentence')))
 .show(truncate=False))
 
from pyspark.sql.functions import split, explode
shakeWordsDF = (shakespeareDF
                .select(explode(split(shakespeareDF.sentence, " ")).alias("word"))

shakeWordsDF = shakeWordsDF.where(shakeWordsDF.word!="")

from pyspark.sql.functions import desc
topWordsAndCountsDF = shakeWordsDF.groupBy('word').count().sort(desc("count"))

```

