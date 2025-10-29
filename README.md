# Marks.nvim

https://github.com/user-attachments/assets/34b572d2-3988-44a1-a597-10d9a90ac9a8

<p align="center" style="italic">Minimal Nvim Marks Viewer</p>

## Usage

- Create a mark pressing `m` followed by a letter (uppercase for global marks).
- Delete a mark pressing `dm` followed by mark letter identifier you want to remove.

## Installation

### Lazy.nvim

*default configuration*

```lua
{
    "cmoisdead/marks.nvim",
    config = function()
        require('marks').setup {
            enabled = true,
            wrap_m = true,
            refresh_delay_ms = 10,
        }
    end
}
```
