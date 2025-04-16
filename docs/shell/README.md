# Shell Script

## How To Run

- First, new a file with no or `.sh` extension. such as 'echo.sh'.
- Then type the content, such as
  ``` shell
  #!/bin/bash
  echo "Hello world!"
  ```

- Add executable permission.
  ```shell
  chmod +x echo.sh
  ```
  There, `+` means 'add', `x` means 'executable'

- Finally, at this folder in terminal, run `./echo.sh` to execute it.
- Verify. If you see 'Hello world!', it means you have succeed it.

## Explain

- Every file is named as this command, its usage will be add in the file.
- This I will explain some common question.

### `#!/bin/bash`

- This is named 'shebang'. This is one shell's full location.
- There, it means you will run this as `/bin/bash filename`.
- You also can use `sh filename` to run a file, even you didn't add executable permission. If so, the `#!/bin/bash` is useless.
- In bash, one semicolon ';' in line can separate one command to two.

- bash不区分单双引号

# ATTENTION

- Those all are written and tested under zsh shell, not bash, maybe it will have different.
- I'm a newbie.
