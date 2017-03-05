
项目中主要使用 jeckins 做持续集成，已经配置好，处于学习和个人项目的目的，学习使用 travis ci。

## 基本配置
1. 要使用 github 账户登录 [travis_ci](https://travis-ci.org/)
2. 在需要 ci 的项目下创建 `.travis.yml` 文件，然后在其中规定一下内容：
3. 你的项目使用了那种编程语言
4. 在每次构建前，需要执行那些命令和脚本
5. 运行 test suite 需要什么指令
6. 构建失败时如何通过 email、Campfire、IRC 来进行通知

## [自定义构建过程](https://docs.travis-ci.com/user/customizing-the-build/)

1. `OPTIONAL Install apt addons`
2. `OPTIONAL Install cache components`
3. `before_install`
4. `install`
5. `before_script`
6. `script`
7. `OPTIONAL before_cache (for cleaning up cache)`
8. `after_success or after_failure`
9. `OPTIONAL before_deploy`
10. `OPTIONAL deploy`
11. `OPTIONAL after_deploy`
12. `after_script`

### install 语句

注意使用脚本时，要 chmod +x, 并有对应的执行程序，如 /usr/bin/env python。

```bash
install: ./install-dependencies.sh

install:
  - bundle install --path vendor/bundle
  - npm install

install: true   // 跳过
```

### script 语句

多个 script 语句若有一个执行失败，会继续执行，但是整个 script 语句最终会失败。

```
script: bundle exec thor build

script:
  - bundle exec rake build
  - bundle exec rake builddoc

script: bundle exec rake build && bundle exec rake builddoc
```

### 构建终止

1. `before_install`, `install`, `before_script` 如果返回一个非零的 code，构建将会立即终止。
2. script 如果返回一个非零的 exit code，构建将会失败，但是 build 会继续，指导收到失败为止。
3. `after_success`, `after_failure`, `after_script` 失败不会对构建造成影响。

### 部署代码

可以部署到 Heroku、Engine Yard 等不同的平台。
为了避免 travis ci 修改你工作目录下的文件，需要运行 `git stash --all`，可以在 `.travis.yml` 文件中做如下的配置：

```
deploy:
  skip_cleanup: true
```

也存在 `before_deploy`，其非零的返回语句会导致构建的失败。
当然也有对应的 `after_deploy` 语句。

### git clone 的深度
默认深度是 50 个 commit。

在配置文件中设定如下：
```
git:
  depth: 3
```

### 构建特定的分支

```
# blocklist
branches:
  except:
  - legacy
  - experimental

# safelist
branches:
  only:
  - master
  - stable
```

如果同时设定了 `only` 和 `except`，`only` 会具有优先作用。 `gh-pages` 分支不会被 built 除非你将其添加到 safelist 中如下:

```
branches:
  only:
    - gh-pages
    - /.*/
```

也可以使用 regular expressions 如下：

```
branches:
  only:
  - master
  - /^deploy-.*$/
```

### 其他

+ 运行时间的限制，build timeout
+ 设定特定的运行语言
+ 使用 apt 安装相关的包
+ 设定并发限制


以后，该项目的提交都会自动跑 travis ci，完成自动测试。

