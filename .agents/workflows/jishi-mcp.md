---
description: 如何使用即时设计 MCP 获取设计稿数据和导出图片素材
---

# 即时设计 MCP 使用指南

## 前提条件
1. MCP 配置文件位于 `~/.gemini/antigravity/mcp_config.json`，内容为：
```json
{
  "mcpServers": {
    "jishi-design": {
      "command": "node",
      "args": [
        "/Users/chandyoung/.nvm/versions/node/v24.13.1/lib/node_modules/@jiujiang/jishi-mcp-server/dist/index.js"
      ]
    }
  }
}
```
2. 即时设计网页端需要已打开目标设计稿
3. 即时设计中的「即时MCP」插件需要已启动（确保 WebSocket 连接到 localhost:19999）

## 可用的 MCP 工具

MCP server 名称：`jishi-design`，提供以下工具：

| 工具 | 用途 | 关键参数 |
|------|------|---------|
| `get_page_nodes` | 获取当前页面所有顶层节点 | 无 |
| `get_selection` | 获取当前选中元素的详细属性和子节点 | `maxDepth`(默认6), `maxNodes`(默认500) |
| `get_node_children` | 按名称或ID获取指定节点的子节点 | `name` 或 `id`, `maxDepth`, `maxNodes` |
| `save_image` | 导出节点为图片文件 | `nodeId`, `format`(PNG/JPG/SVG/PDF), `scale`, `savePath` |
| `download_icons` | 批量导出节点为 SVG | `nodeIds`(数组) |
| `execute_script` | 在即时设计插件中执行 JS 代码 | `code` |

## 典型工作流程

1. **先用 `get_page_nodes` 查看页面结构**，找到目标设计页面/画板
2. **用 `get_selection` 或 `get_node_children` 获取设计数据**，包括布局、颜色、字体等属性
3. **用 `save_image` 导出图片素材**，指定 `savePath` 保存到项目目录
4. **根据获取的设计数据编写代码**，精确还原设计稿

## 注意事项
- 不需要手动写 JavaScript 脚本来提取设计数据，直接使用 MCP 工具即可
- `save_image` 的 `savePath` 使用绝对路径，图片会直接保存到指定位置
- 如遇到「插件未连接」错误，请在即时设计中重新打开「即时MCP」插件

## 故障排查
- 如果 npm/npx 报 EPERM 权限错误，运行：`sudo xattr -r -d com.apple.provenance ~/.npm && sudo chown -R $(whoami) ~/.npm`
- 如果端口 19999 被占用，运行：`kill $(lsof -t -i :19999)` 然后重启 Antigravity
