# thirst.lua
Thirst is a variation of [lust](https://github.com/bjornbytes/lust/) that seeks to
remove as much of the slog of writing unit tests as possible.

The more frictionless it is to write tests, the more you'll want to do it, and the
better off your codebase will be in the long run. This is especially important for
weakly-typed, dynamic languages like Lua.


<table>
<tr>
<td> Before </td> <td> After </td>
</tr>
<tr>
<td>

```swift
struct Hello {
   public var test: String = "World" // original
}
```

</td>
<td>

```swift
struct Hello {
   public var test: String = "Universe" // changed
}
```
</td>
</tr>
</table>

