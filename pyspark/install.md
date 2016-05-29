
1. 安装homebrew
2. brew install python
3. pip install --upgrade pip
4. 使用python安装requirement中依赖的项目。
5. 在.bash_profile中配置以下项目：
```
# pyspark run in jupyter notebook
export PATH="/Users/ly/Software/spark-1.6.1-bin-hadoop2.6/bin:$PATH"
# 安装的spark开发环境目录
export PYSPARK_DRIVER_PYTHON=ipython
export PYSPARK_DRIVER_PYTHON_OPTS='notebook' pyspark
```