
使用 rust 实现一个 Linked List，这会使用到以下 rust 的高级特性：

+ 以下的引用类型： `&`, `&mut`, `Box`, `Rc`, `Arc`, `*const`, `*mut`
+ Ownership, borrowing, inherited mutability, interior mutability, Copy
+ 所有的关键字： struct、enum、fn、pub、impl、use
+ Pattern matching、generics、destructors
+ Testing
+ 基本的 Unsafe rust

## A Bad Stack

1. std::boxed::Box - Rust 一个用于堆分配的指针类型。 [box doc](https://doc.rust-lang.org/std/boxed/)
为什么需要 box？因为在 rust 中，List 的尺寸取决于其中包含有多少元素，因而我们需要知道给 List 分配多少内存，通过引入一个 Box，拥有一个定义好的 size， 我们知道了 Cons 究竟有多大。

递归的结构体必须进行 box。

Rust 臭名昭著的内存替换： `mem::replace`

+ `diverging function` 永远不会返回给调用者，所以可以用于替换任何期待的值。
+ Box 值的 * DerefMove、Deref、DerefMut

```rust
pub trait Drop {
    fn drop(&mut self);
}
```

rust 和 C++ 类似，使用 destructors 来自动地清除那些自己不需要的资源，典型地是使用了一个 trait。自动的 drop 会引起问题，因为对于 list，他们通常是 递归的。
默认的析构器是在作用域结束时，递归地调用析构器。 list -> A -> B -> C

