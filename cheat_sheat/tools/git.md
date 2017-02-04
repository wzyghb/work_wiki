
git 是最常用的开发版本管理、协作工具，应该能够熟练地、全面地掌握。不但要熟悉基本命令的意义，也要掌握对应的开发流程。

# 最佳实践

### 1. 最常见case, 基于master分支开发

```
git pull --rebase # 先更新代码，基于最新代码进行开发
# edit, commit, edit, commit, ...
git pull --rebase # 或git fetch; git rebase origin/master 讲远程分支的内容合并到本地分支。
git push origin master:master
```

### 2. short-running topic branch (本地分支，不需多人协作)

```
git fetch
git checkout -b impr-pubtime-ex origin/master # 创建短期分支
# edit, commit, edit, commit
git checkout master                         # 切换回当前主分支
git pull --rebase                           # 合并远程主分支
git merge impr-pubtime-ex                   # 合并当前短分支
# 若希望始终生成merge, 则 git merge --no-ff impr-pubtime-ex
# --on-ff 即使是fast-forward，也会生成一个commit
git push origin master:master               # 讲本地主分支推送到远程库

# 删除分支
git branch -d impr-pubtime-ex
```

### 3. long-running topic branch (本地分支，不需多人协作)

```
git checkout -b new-abtest origin/master
 
# 以下步骤可反复进行多次 长期分支需要在开发过程中不断进行合并远程分支
 
# edit, commit, edit, commit
# 合并入最新代码，以进行测试(很多情况不需更新到最新代码)
git fetch
git rebase -i origin/master     # -i 表示具备交互功能
 
# topic完结，合并到主干 提交到远程分支
git checkout master
git pull --rebase
git merge new-abtest # 若希望始终生成merge, 则 git merge --no-ff impr-pubtime-ex
git push origin master:master
 
# 删除本地topic 分支
git branch -d new-abtest
```

### 4. fork开源代码修改，并不断merge对方的更新

```
git clone git@git.bytedance.com:git
cd git
git remote add -f gh git://github.com/git/git.git # 获取github的代码，将这个远程库取名为gh
# edit, commit, edit, commit
git push origin master:master   ＃ 传送到公司本地的线上代码库
 
# 周期merge对方的更新
git pull --rebase               # 更新自己的代码到最新
git pull gh master              # merge github的代码
git push origin master:master   # push到服务器
```

### 5. rebase之后冲突的解决

```
# 解决冲突，然后
git rebase --continue # 这个很重要
```

### 6. 修改最新commit的message

```
git commit --amend
```

### 7. 修改第三个commit (HEAD~2) 的message

```
git rebase -i HEAD~3
# 在弹出编辑窗口中，将第一个pick改为reword, 保存退出
```

### 8. 合并commit

开发时在本地可以任意提交，作为check point保存, commit message可以写得很随意。
但在给别人review之前，应该把相关的commit合并到一起，并refine commit message

```
git rebase -i HEAD~4
# 在弹出编辑窗口中，change 某些 pick为squash，保存退出。(如有必要，可交换commit的顺序)
# 在又新弹出的窗口中，编辑commit message，保存退出.
# 此过程反复，直至结束
```

### 9. 使用topic branch解决某个比较复杂的issue

```
git checkout -b myjaws korg/jaws
git checkout -b wifi-hang
# edit, commit, edit, commit
# ask for review and pass the review
git checkout myjaws
git merge --no-ff wifi-hang
git commit --amend # add Issue, Reviewed-by
git push korg myjaws:jaws
```

### 10. experiment branch的修改被废弃，但其中某一个commit的修改需要apply到master branch

```
git checkout master # 切换到master
git cherry-pick experiment~1 # 将experiment branch的第二个commit apply到master
git branch -D experiment # 删除此branch
```

### 11. 解决issue1过程中，需要紧急解决issue2

```
git checkout -b issue1 origin/master
# edit, commit, edit,
# 被中断，需要先解决issue2
git commit -a -m "temp check point"
git checkout -b issue2 origin/master
# edit, commit, ...
git push origin issue2:master
git checkout issue1
git rebase -i origin/master
git reset HEAD^ # 回退之前的临时提交
# edit, commit, ...
git push origin issue1:master
```

### 撤销操作

让工作目录回到上次提交时的状态：

+ git reset --hard HEAD   # 到最近的commit，且删除修改
+ git reset HEAD          # 到最近的commit，并且保留所有更改
+ git reset xxxxx         # 将HEAD重置到某个commit的状态，并保留所有更改
+ git checkout -- hello.rb # 将hello.rb从最近的commit中取出，并恢复为那时的状态

# 复杂命令

## 1. git stash

+ git stash list
+ git stash apply
+ git stash apply --index
+ git stash clear
+ git stash show -p stash@{0} | git apply -R
+ git stash branch testchanges // stash branch 从 stash 创建一个分支
+ git stash drop stash@{0}


## 2. git revert

## 3. git cherry-pick
+ git cherry-pick <commit id> 将对应的commit应用到当前分支
