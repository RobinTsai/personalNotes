# Learn Sass

+ link: http://www.w3cplus.com/sassguide/
+ A more easy with css style.

## define variable.
  + with "$"
  + `$fontStack: sans-serif, Helvetica;`
  + use $fontStack instead of `sans-serif, Helvetica`

## nested (qian tao)
  ```sass
    nav{
      ul{
        margin:0;
      }
    }
  ```
  instead of :

  ```css
    nav ul {
      margin:0;
    }
  ```

## import
  + use `@import 'filename';`

## use mixin define some code
  ```sass
    @mixin box-sizing ($sizing) {
      box-sizing: $sizing;
    }
    .box-border {
      @include box-sizing(border-box);
    }
  ```
