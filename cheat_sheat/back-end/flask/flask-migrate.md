
# 1 基本的命令
| 命令           | 说明 |  
|---            |:------:|  
| downgrade     | Revert to a previous version|
| merge         | Merge two revisions together. Creates a new migration file|
| branches      | Show current branch points|
| revision      | 创建一个新的版本更新文件 |
| history       | 显示按时间排序的版本信息 |
| upgrade       | Upgrade to a later version|
| heads         | 显示当前脚本下可用的 heads 信息（多个分支才会有） |
| current       | 显示当前版本的 reversion 信息（只有版本号） |
| show          | 显示给定版本的 reversion 信息 |
| init          | 初始化一个新的迁移 |
| stamp         | 'stamp' the revision table with the given revision; don't run any migrations|
| migrate       | Alias for 'revision --autogenerate'|
| edit          | 编辑当前数据库的 commit 信息 |

# 2 基本使用

> pip install Flask-Migrate

```python
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_script import Manager
from flask_migrate import Migrate, MigrateCommand

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///app.db'

db = SQLAlchemy(app)
migrate = Migrate(app, db)

manager = Manager(app)
manager.add_command('db', MigrateCommand)

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(128))

if __name__ == '__main__':
    manager.run()
```

> flask db init  
> flask db migrate  
> flask db upgrade  
> flask db --help  

# 3 细节

## 1 配置回调

动态地将自己的配置写入到 Alembic 配置中。一个使用 configure 回调装饰的函数会在配置读取时回调。函数会修改配置对象，将其替换为一个全新的配置对象。

```python
@migrate.configure
def configure_alembic(config):
    # modify config object
    return config
```

## 2 多个数据库支持

Flask-SQLAlchemy 具有 binds 特征，Flask-Migrate 集成了这个特征。

> flask db init --multidb

## 命令索引

flask_migrate 导出了两个类，Migrate 和 MigrateCommand。Migrate 类包括了所有扩展的功能。
而 MigrateCommand 类则向 Flask-Script 导出了 Flask 迁移的命令。

+ flask db --help  
+ flask db init [--multidb]
+ flask db revision [--message MESSAGE] [--autogenerate] [--sql] [--head HEAD] [--splice] [--branch-label BRANCH_LABEL] [--version-path VERSION_PATH] [--rev-id REV_ID]
+ flask db migrate [--message MESSAGE] [--sql] [--head HEAD] [--splice] [--branch-label BRANCH_LABEL] [--version-path VERSION_PATH] [--rev-id REV_ID]
+ flask db edit <revision>
+ flask db upgrade [--sql] [--tag TAG] [--x-arg ARG] <revision>
+ flask db downgrade [--sql] [--tag TAG] [--x-arg ARG] <revision>
+ flask db stamp [--sql] [--tag TAG] <revision>     
+ flask db current [--verbose]      展示当前的版本
+ flask db history [--rev-range REV_RANGE] [--verbose]
+ flask db show <revision>      展示特定版本
+ flask db merge [--message MESSAGE] [--branch-label BRANCH_LABEL] [--rev-id REV_ID] <revisions>
+ flask db heads [--verbose] [--resolve-dependencies]
+ flask db branches [--verbose]
