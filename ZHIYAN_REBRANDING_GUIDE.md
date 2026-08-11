# ZhiyanFlow 轻量二开换标指导手册

> 适用场景：基于一个已有开源或商业授权项目进行轻量二次开发，主要目标是替换为智研品牌，而不是改写核心业务。
>
> 默认目标产品名：`ZhiyanFlow`。实际执行时，应将文中的 `XXX` 替换为具体产品后缀。
>
> 本手册基于 ZhiyanMind Windows 桌面项目的实际换标、打包、安装和本机部署经验整理。

## 1. 二开的目标与边界

轻量换标二开的目标不是“把源码中的原产品名全部替换掉”，而是完成以下四件事：

1. 用户看到的产品身份统一变为 `ZhiyanFlow`。
2. Windows、macOS、Linux 安装和运行产物使用新的名称、图标和元数据。
3. 原项目的核心代码、内部协议、包名、命令、存储结构和升级链路尽量保持兼容。
4. 二开版本使用独立数据目录和私有源码，不污染原项目的安装和用户数据。
5. 后端保持与上游滚动同步（最小化差异以便快速 merge），前端仅做品牌化轻改（名称、Logo、颜色、首屏），不重写业务逻辑和架构。这种"薄包装"策略确保每次上游更新，ZhiyanFlow 只需极低维护成本即可跟上。

换标工作的核心原则是：后端保持滚动，前端品牌化轻改——后端代码尽可能与上游一致以便快速同步更新，前端仅做品牌层面的轻量替换。具体来说：

```text
改外壳，保内核；改显示，保协议；改产品身份，保兼容链路。
```

如果需求只是“换成我们的标”，不得顺手重构业务代码、替换技术栈或修改核心行为。

## 2. 开工前必须确定的品牌参数

每个项目开始前，先填写一份品牌参数表。后续所有文件必须引用同一组结果，禁止不同模块自行起名。

| 参数 | 示例 | 说明 |
| --- | --- | --- |
| 原产品名 | `OriginalProduct` | 上游对外产品名称 |
| 新产品名 | `ZhiyanFlow` | 用户看到的正式名称 |
| 品牌短名 | `ZhiyanFlow` | 窗口、菜单和 About 使用 |
| 小写标识 | `zhiyanflow` | 目录、包标识或 URL slug |
| Windows EXE | `ZhiyanFlow.exe` | 主程序文件名 |
| 安装包名 | `ZhiyanFlow-${version}-${os}-${arch}.${ext}` | 可追踪版本和架构 |
| App ID | `com.zhiyanwanwu.zhiyanflow` | Electron/Tauri/Windows 身份 |
| 安装器 App ID | `com.zhiyanwanwu.zhiyanflow.setup` | 与主程序分开 |
| Windows 快捷方式 | `ZhiyanFlow` | 桌面和开始菜单名称 |
| 卸载项 | `ZhiyanFlow` | Windows 应用列表显示名 |
| 独立数据目录 | `%LOCALAPPDATA%\ZhiyanFlow` | 避免污染原项目 |
| 私有源码目录 | `%LOCALAPPDATA%\ZhiyanFlow\source` | 运行时固定使用私有源码 |
| 法律主体 | 待确认 | 未提供新主体时不得擅自改公司名和版权 |
| 内部协议 scheme | 通常保留原值 | 例如 `originalapp://`，除非完成兼容迁移 |
| 内部 CLI 命令 | 通常保留原值 | 避免脚本、插件和文档失效 |

### 2.1 Logo 输入要求

开始前至少准备：

- 一张透明背景的方形 Logo，建议为 1024x1024 PNG。
- 一张横向“图标 + ZhiyanFlow 文字”的品牌图，供首屏和安装器使用。
- 品牌标准色值，例如 HEX、RGB。
- 明确浅色和深色背景下的展示规则。
- 确认 Logo 和品牌名称的使用权。

Windows ICO 至少应包含：

```text
16x16, 24x24, 32x32, 48x48, 64x64, 128x128, 256x256
```

所有平台图标必须由同一份源 Logo 生成，避免 exe、任务栏、安装器和首屏使用不同版本。

## 3. 不可破坏的二开原则

### 3.1 先读源码和构建链，再修改

必须先查清：

- 项目使用 Electron、Tauri、Qt、.NET、Flutter 还是其他桌面框架。
- 主程序由哪个配置文件决定名称和图标。
- 安装包由 NSIS、MSI、WiX、Inno Setup、Tauri Bundle 或其他工具生成。
- 是否存在 bootstrap 安装器、自动更新器和二次启动器。
- 后端、CLI、前端和桌面壳是否为不同 workspace。
- 首次启动是否会从官方仓库下载安装脚本或源码。

没有完成源码审计前，不允许直接全局替换。

### 3.2 禁止对原产品名做全仓库无脑替换

同一个旧名称可能同时代表：

- 用户可见品牌。
- npm/Python/Rust 包名。
- CLI 命令。
- URL scheme。
- 环境变量前缀。
- 数据库表、存储键和配置键。
- GitHub 仓库路径。
- 更新服务器地址。
- 第三方 API 协议字段。

只有第一类通常必须替换。其他类别要逐项判断兼容性。

### 3.3 用户可见身份与内部身份分层

建议按以下三类建立换标矩阵：

| 类型 | 默认策略 | 典型内容 |
| --- | --- | --- |
| 用户可见 | 替换 | 窗口标题、Logo、欢迎页、About、安装器文案 |
| 系统产品身份 | 替换 | exe 名、App ID、快捷方式、卸载项、PE ProductName |
| 内部兼容身份 | 保留 | 包名、CLI、scheme、数据库键、旧数据迁移标识 |

### 3.4 版本信息可以隐藏，但不能删除

如果界面不需要显示版本号，应隐藏相应 UI 项，而不是删除版本字段或构建元数据。

版本号仍可能被以下功能依赖：

- 自动更新判断。
- 安装包命名。
- 崩溃报告和日志。
- 后端兼容检查。
- Windows 文件属性。

### 3.5 不在源码中保存 GitHub Token

私有仓库的凭据只能由本机凭据管理器、CI Secret、SSH Key 或短期环境变量提供。

禁止把 Token 写入：

- Git remote URL。
- 启动脚本。
- `.env.example`。
- Electron/Tauri 配置。
- 安装包资源。
- 日志。

### 3.6 法律信息不得凭空修改

`CompanyName`、`Publisher`、`LegalCopyright` 和许可证声明属于法律信息。

如果没有收到新的公司主体和授权信息：

- 产品名和描述可以改为 `ZhiyanFlow`。
- 原作者、原版权和许可证必须保留。
- 不得把原作者版权直接改成智研主体。

### 3.7 后端保持滚动，前端品牌化轻改

这是 ZhiyanFlow 项目的核心差异化策略：

**后端：保持滚动更新**

- 后端代码尽可能与上游（upstream）保持一致，不做结构性修改。
- 只做最小必要的兼容性适配（如端口配置、路径调整等），不重构后端架构。
- 当上游发布新版本时，通过 `git merge upstream/main` 或 `git rebase` 快速同步更新。
- 后端包名、CLI 命令、API 路由、数据库结构、环境变量前缀和内部协议全部保留原值。
- 这样做的好处：上游每次更新，你只需处理极少的合并冲突，维护成本趋近于零。

**前端：品牌化轻量修改**

- 前端只做品牌层面的轻量修改：产品名、Logo、品牌色、首屏样式、About 页面等。
- 不改动前端的业务逻辑、路由结构、组件架构或状态管理。
- 自定义 CSS / 主题变量覆盖而非直接修改上游组件源码，优先使用品牌变量注入。
- 当上游前端有重大更新时，只需重新应用品牌变量和资源替换即可，无需重写。

**策略优势**

```text
上游更新 → git merge → 自动解决大部分冲突 → 重新构建 → 即完成同步
后端：接近零改动    前端：仅品牌层替换
```

这种"薄包装"（Thin Wrapper）模式确保 ZhiyanFlow 可以几乎零延迟地跟上上游的每一次迭代，同时保持独立的品牌身份。

**实施要点**

1. 在源码审计阶段就明确区分：哪些是后端核心代码（不动），哪些是前端品牌层（可改）。
2. 在 Git 分支策略上：`main` 跟踪上游，`branding` 分支叠加品牌改动，每次上游更新先 merge 到 `main`，再 rebase `branding`。
3. 前端品牌的修改应集中在一组可识别的文件或目录中，方便审计和重新应用。
4. 构建脚本应支持"品牌资源覆盖目录"机制：将品牌资源放在独立目录，构建时覆盖默认资源。

## 4. 源码审计流程

### 4.1 保存基线

执行修改前记录：

```powershell
git status --short --branch
git log --oneline --decorate -5
git remote -v
```

如果工作区已有用户改动，必须保留并避开，不得重置或覆盖。

### 4.2 阅读仓库规则

优先查找并完整阅读：

```powershell
rg --files -g "AGENTS.md" -g "CONTRIBUTING.md" -g "README*.md"
```

同时检查根目录和目标子目录中是否有更具体的规则文件。

### 4.3 搜索品牌入口

推荐先搜索，不要立即替换：

```powershell
rg -n "OriginalProduct|Original Product|original-product|original_product" . \
  -g "!node_modules/**" \
  -g "!dist/**" \
  -g "!release/**" \
  -g "!build/**"
```

按下面的分类记录结果：

1. 首屏、导航栏、状态栏和 About。
2. 多语言 i18n 文案。
3. HTML title、manifest 和 meta 标签。
4. Electron/Tauri/Flutter/.NET 产品配置。
5. Windows PE 元数据。
6. 安装器、快捷方式和卸载项。
7. 图标、favicon、Apple touch icon。
8. 自动更新和首次 bootstrap 地址。
9. 内部包名、CLI、scheme、存储键。
10. 测试、快照和构建脚本中的断言。

### 4.4 跑一次未修改的基线

至少记录：

- 类型检查是否通过。
- lint 是否通过。
- 单元测试是否有既有失败。
- 生产构建是否能生成。
- Windows 打包是否能完成。
- 原项目是否能在本机启动。

既有失败必须单独记录，不能在换标完成后全部归咎于本次改动。

### 4.5 输出审计结论

正式修改前应先形成一张表：

| 检查项 | 当前状态 | 计划动作 | 风险 |
| --- | --- | --- | --- |
| 首屏 Logo | 原品牌 | 替换 | 低 |
| exe 文件名 | 原名称 | 替换 | 中 |
| 协议 scheme | 原名称 | 保留 | 高 |
| Python 包名 | 原名称 | 保留 | 高 |
| bootstrap URL | 官方仓库 | 改私有部署策略 | 高 |
| 右下角版本 | 可见 | 仅隐藏 UI | 低 |

## 5. Git 和仓库策略

### 5.1 推荐 remote 结构

```text
origin   -> 智研私有二开仓库，可推送
upstream -> 原项目官方仓库，只拉取，禁止推送
```

示例：

```powershell
git remote set-url origin <PRIVATE_REPO_URL>
git remote add upstream <OFFICIAL_REPO_URL>
git remote set-url --push upstream DISABLED
git remote -v
```

### 5.2 分支建议

```text
main                         稳定二开版本
branding/zhiyanflow           首次换标
fix/zhiyanflow-windows-shell  Windows 壳修复
sync/upstream-YYYYMMDD       上游同步验证
```

每次换标应从当前稳定二开分支创建独立分支，不直接在上游分支工作。

### 5.3 判断能否合并上游

先检查共同祖先：

```powershell
git fetch upstream
git merge-base main upstream/main
```

- 有共同祖先：可以在隔离分支中 rebase、merge 或 cherry-pick。
- 没有共同祖先：说明私有仓库可能是快照导入，不要直接强行合并。
- 快照仓库应采用人工对比、补丁迁移或重新建立可追踪历史。

禁止为了省事使用 `--allow-unrelated-histories` 把两个巨大历史直接混在一起。

## 6. 分层换标实施方法

### 6.1 第一层：品牌资源

建立唯一源资源，然后派生：

```text
brand-source/
  zhiyanflow-logo-square.png
  zhiyanflow-wordmark.png
```

常见替换位置：

```text
assets/icon.ico
assets/icon.png
public/favicon.ico
public/apple-touch-icon.png
src/assets/zhiyanflow-icon.png
src-tauri/icons/32x32.png
src-tauri/icons/128x128.png
src-tauri/icons/128x128@2x.png
src-tauri/icons/icon.ico
```

验收要求：

- 图标背景透明或符合品牌规范。
- 16x16 下仍能辨识。
- Windows 文件、任务栏和快捷方式图标一致。
- 安装器和主程序来自同一 Logo。
- 不使用网页截图直接缩小作为 ICO。

### 6.2 第二层：用户可见 UI

替换范围通常包括：

- 首屏 Logo 和 `ZhiyanFlow` wordmark。
- HTML title 和桌面窗口标题。
- About 对话框。
- 欢迎、加载、更新、成功和失败文案。
- 设置页中的产品名称。
- 安装和卸载提示。
- 多语言文件中的品牌名称。

示例：

```text
OriginalProduct is ready  -> ZhiyanFlow is ready
Setting up OriginalProduct -> Setting up ZhiyanFlow
Updating OriginalProduct   -> Updating ZhiyanFlow
About OriginalProduct      -> About ZhiyanFlow
```

替换 i18n 时只替换品牌词，不要顺手改写整段翻译。

如果要求隐藏右下角版本号：

- 保留版本状态和更新逻辑。
- 在 UI item 上设置隐藏条件，或从渲染列表中过滤。
- 为“版本项不显示”增加聚焦测试。

### 6.3 第三层：Electron 产品身份

Electron Builder 常见配置示例：

```json
{
  "name": "保留原 workspace 名",
  "productName": "ZhiyanFlow",
  "build": {
    "appId": "com.zhiyanwanwu.zhiyanflow",
    "productName": "ZhiyanFlow",
    "executableName": "ZhiyanFlow",
    "artifactName": "ZhiyanFlow-${version}-${os}-${arch}.${ext}",
    "win": {
      "icon": "assets/icon.ico",
      "legalTrademarks": "ZhiyanFlow"
    },
    "nsis": {
      "shortcutName": "ZhiyanFlow",
      "uninstallDisplayName": "ZhiyanFlow"
    }
  }
}
```

Electron 主进程还应统一：

```ts
const APP_NAME = process.env.ORIGINAL_DESKTOP_APP_NAME || 'ZhiyanFlow'

app.setName(APP_NAME)
app.setAppUserModelId('com.zhiyanwanwu.zhiyanflow')
app.setAboutPanelOptions({ applicationName: APP_NAME })
```

注意：

- `appId` 和 `setAppUserModelId()` 必须一致。
- npm workspace 名称通常不改。
- 已发布的 URL scheme 通常不改。
- 改 scheme 前必须设计旧链接兼容和迁移方案。

### 6.4 第四层：Windows PE 元数据

仅修改 `productName` 并不能保证文件属性正确。

最终 exe 应检查：

- `ProductName = ZhiyanFlow`
- `FileDescription = ZhiyanFlow`
- `CompanyName = 合法主体`
- 文件图标为智研 Logo
- 文件名为 `ZhiyanFlow.exe`

如果构建工具跳过 PE 资源编辑，可在 `afterPack` 中使用 `rcedit` 等工具补写：

```js
await rcedit(exePath, {
  icon: iconPath,
  'version-string': {
    ProductName: 'ZhiyanFlow',
    FileDescription: 'ZhiyanFlow',
    CompanyName: '<LEGAL_COMPANY>',
    LegalCopyright: '<LEGAL_COPYRIGHT>'
  }
})
```

不得因为签名工具下载失败，就跳过图标和 PE 身份验收。

### 6.5 第五层：安装器身份

需要检查所有安装器，而不仅是主程序：

- NSIS/MSI/Inno Setup 产品名。
- Tauri `productName` 和 `identifier`。
- 安装器窗口标题。
- 安装器 manifest description。
- 欢迎、进度、成功和失败页。
- 桌面快捷方式。
- 开始菜单快捷方式。
- Windows 卸载项。
- 卸载程序文件名。

Tauri 示例：

```json
{
  "productName": "ZhiyanFlow Setup",
  "identifier": "com.zhiyanwanwu.zhiyanflow.setup",
  "app": {
    "windows": [{ "title": "ZhiyanFlow Setup" }]
  },
  "bundle": {
    "shortDescription": "ZhiyanFlow Setup",
    "longDescription": "Installs ZhiyanFlow on your machine."
  }
}
```

### 6.6 第六层：自动更新和首次启动

这是换标项目最容易漏掉的高风险部分。

如果桌面程序内置如下流程：

```text
读取构建 commit -> 从官方 GitHub raw URL 下载 install.ps1 -> 安装后端
```

那么私有 branding commit 不存在于官方仓库时，全新环境会出现 404。

可选解决方案：

1. 把安装脚本随应用打包，优先使用本地副本。
2. 把更新源改为有权限控制的私有 Release 服务。
3. 在本机预部署私有源码，并通过启动器显式指定源码目录。
4. 构建安装包时写入私有仓库可访问的 commit 和 branch。

禁止把 GitHub Token 嵌入客户端来解决私有仓库访问。

## 7. 内部兼容标识的处理规则

以下内容默认保留，除非需求明确要求迁移：

| 内容 | 为什么保留 |
| --- | --- |
| npm/Python/Rust 包名 | 插件、import 和 workspace 依赖它 |
| CLI 命令 | 用户脚本和子进程调用依赖它 |
| URL scheme | 历史深链和 OAuth 回调依赖它 |
| 环境变量前缀 | 安装脚本和后端解析依赖它 |
| 数据库名称和表名 | 改名可能导致旧数据不可见 |
| localStorage/IndexedDB key | 改名会让前端像全新安装 |
| IPC channel | 主进程和渲染进程契约依赖它 |
| 后端模块和目录结构 | 启动、升级和插件发现依赖它 |

如果最终确实要改，必须同时提供：

- 旧值兼容读取。
- 新值写入。
- 一次性迁移。
- 回滚路径。
- 自动化测试。

## 8. 本机隔离部署策略

二开版本应使用独立目录：

```text
%LOCALAPPDATA%\ZhiyanFlow\
  source\
  logs\
  config\
  desktop-user-data\
  Start-ZhiyanFlow.ps1
```

不要直接复用原产品的数据目录，否则可能出现：

- 配置相互覆盖。
- 登录态串用。
- 数据库版本冲突。
- 原版和二开版无法同时运行。
- 卸载一个产品破坏另一个产品。

### 8.1 通用启动器模板

不同项目的环境变量名称不同。下面是结构模板，不得未经源码确认就照抄变量名：

```powershell
param(
  [string]$AppPath = "$env:LOCALAPPDATA\Programs\ZhiyanFlow\ZhiyanFlow.exe",
  [string]$ProductHome = "$env:LOCALAPPDATA\ZhiyanFlow",
  [string]$SourceRoot = "$env:LOCALAPPDATA\ZhiyanFlow\source"
)

if (-not (Test-Path -LiteralPath $AppPath -PathType Leaf)) {
  throw "ZhiyanFlow.exe not found: $AppPath"
}

if (-not (Test-Path -LiteralPath $SourceRoot -PathType Container)) {
  throw "Private source not found: $SourceRoot"
}

# 变量名必须替换成原项目已经支持的内部变量。
$env:ORIGINAL_APP_HOME = $ProductHome
$env:ORIGINAL_DESKTOP_SOURCE_ROOT = $SourceRoot
$env:ORIGINAL_DESKTOP_APP_NAME = 'ZhiyanFlow'

Start-Process -FilePath $AppPath -WorkingDirectory (Split-Path -Parent $AppPath)
```

如果 Electron 在某台 Windows 机器上出现 GPU 或缓存崩溃，可增加可选参数：

```powershell
$env:ORIGINAL_DESKTOP_USER_DATA_DIR = "$ProductHome\desktop-user-data"
$env:ORIGINAL_DESKTOP_DISABLE_GPU = '1'
```

这些参数只应作为已验证的兼容措施，不应盲目成为所有机器的默认值。

### 8.2 快捷方式要求

如果必须通过启动器设置环境变量，桌面和开始菜单快捷方式应指向启动器，而不是直接绕过启动器打开 exe。

同时保证：

- 快捷方式名称为 `ZhiyanFlow`。
- 图标仍取自 `ZhiyanFlow.exe`。
- PowerShell 窗口隐藏。
- 工作目录指向应用目录。
- 二次点击聚焦已有实例，而不是无限创建进程。

## 9. 构建和测试门禁

测试规模应与改动风险匹配。轻量换标至少需要以下门禁。

### 9.1 静态检查

```powershell
git diff --check
```

然后执行项目自身的：

- branding 相关文件 lint。
- 桌面端类型检查。
- 安装器类型检查。
- 受影响的聚焦单元测试。

### 9.2 生产构建

必须验证：

- 前端 production build。
- Electron/Tauri 主进程构建。
- Windows unpacked 构建。
- NSIS/MSI 安装包构建。
- 如果存在 bootstrap 安装器，也要单独构建。

### 9.3 PE 元数据检查

```powershell
$vi = (Get-Item '.\release\win-unpacked\ZhiyanFlow.exe').VersionInfo

[pscustomobject]@{
  ProductName = $vi.ProductName
  FileDescription = $vi.FileDescription
  CompanyName = $vi.CompanyName
  OriginalFilename = $vi.OriginalFilename
  FileVersion = $vi.FileVersion
  ProductVersion = $vi.ProductVersion
} | Format-List
```

安装包本身也要执行同样检查。

### 9.4 Windows 安装检查

安装后确认：

- `%LOCALAPPDATA%\Programs\ZhiyanFlow\ZhiyanFlow.exe` 存在。
- 桌面快捷方式显示 `ZhiyanFlow`。
- 开始菜单显示 `ZhiyanFlow`。
- Windows 卸载项显示 `ZhiyanFlow`。
- `DisplayIcon` 指向新的 exe。
- 卸载程序名称包含 `ZhiyanFlow`。

### 9.5 运行 smoke test

使用独立数据目录启动后验证：

1. 窗口标题为 `ZhiyanFlow`。
2. 首屏 Logo 和 wordmark 正确。
3. 右下角不显示被要求隐藏的版本号。
4. 后端成功启动。
5. 能进入模型配置页。
6. 能进入聊天或主业务界面。
7. 日志中没有私有 commit 对官方 raw URL 的 404。
8. 没有读写原产品的数据目录。
9. 退出后没有遗留异常子进程。

## 10. 完整验收清单

### 10.1 视觉和文案

- [ ] 首屏使用智研 Logo。
- [ ] 首屏文字为 `ZhiyanFlow`。
- [ ] 窗口标题为 `ZhiyanFlow`。
- [ ] About 名称为 `ZhiyanFlow`。
- [ ] 安装、更新、成功和失败文案均已换标。
- [ ] 多语言文件没有明显遗漏。
- [ ] 不再显示被要求删除的版本号 UI。

### 10.2 Windows 身份

- [ ] 主程序文件名为 `ZhiyanFlow.exe`。
- [ ] exe 图标为智研 Logo。
- [ ] PE ProductName 为 `ZhiyanFlow`。
- [ ] PE FileDescription 为 `ZhiyanFlow`。
- [ ] AppUserModelID 为新的智研 ID。
- [ ] 安装包文件名包含 `ZhiyanFlow`。
- [ ] 桌面和开始菜单快捷方式名称正确。
- [ ] Windows 卸载项名称正确。

### 10.3 内部兼容

- [ ] 原 CLI 命令仍可用。
- [ ] 原包名和 import 路径未被误改。
- [ ] 原协议 scheme 仍可用。
- [ ] 原 IPC 和存储键未被误改。
- [ ] 自动更新仍有版本元数据。
- [ ] 旧数据迁移策略明确。

### 10.4 仓库和部署

- [ ] `origin` 指向智研私有仓库。
- [ ] `upstream` 指向官方仓库且禁止推送。
- [ ] 换标在独立分支完成。
- [ ] 私有仓库中没有 Token。
- [ ] 本机使用独立产品目录。
- [ ] 启动器固定使用私有源码。
- [ ] 原产品数据目录没有被修改。

### 10.5 质量门禁

- [ ] `git diff --check` 通过。
- [ ] 受影响文件 lint 通过。
- [ ] 类型检查通过。
- [ ] 聚焦测试通过。
- [ ] 生产构建通过。
- [ ] Windows unpacked 打包通过。
- [ ] Windows 安装包生成成功。
- [ ] 本机启动 smoke test 通过。
- [ ] 既有失败已单独记录。

## 11. 常见错误和处理方法

### 11.1 只改网页 Logo，exe 仍显示 Electron

原因：网页资源和 Windows PE 资源是两套系统。

处理：同时修改构建图标、PE 资源、App ID、快捷方式和安装器配置。

### 11.2 `productName` 已改，但文件属性没有改

原因：构建配置关闭了可执行文件资源编辑，或 afterPack 没有执行。

处理：检查打包日志，并在打包后明确执行 PE stamping。

### 11.3 私有版本首次启动访问官方 raw URL 404

原因：构建 stamp 指向私有 commit，但下载地址仍是官方仓库。

处理：随包附带安装脚本，或预部署私有源码并通过启动器指定。

### 11.4 桌面快捷方式绕过私有环境

原因：快捷方式直接打开 exe，没有经过设置独立目录的启动器。

处理：让快捷方式指向启动器，并继续使用 exe 作为图标源。

### 11.5 安装版崩溃，unpacked 版正常

优先检查：

- 安装目录和 unpacked 目录的文件清单是否一致。
- exe、asar、preload 和资源文件哈希是否一致。
- Electron userData 是否损坏。
- GPU 加速是否触发 Windows 渲染崩溃。
- 单实例锁是否让第二个进程立即退出。

不要仅凭“进程退出”就判断二进制损坏。

### 11.6 全局替换破坏 CLI、scheme 或数据库

原因：把品牌名和内部兼容 ID 当成同一种东西。

处理：按“用户可见 / 系统身份 / 内部兼容”三层重新审计和回退。

### 11.7 为隐藏版本号删除版本逻辑

原因：把 UI 需求误当成构建和更新需求。

处理：恢复版本状态，只隐藏对应 UI item。

## 12. 推荐的 AI 执行流程

将任务交给 Codex 或其他编码 AI 时，要求其按以下阶段工作。

### 阶段 A：只读审计

AI 必须：

1. 阅读仓库规则和构建文档。
2. 检查 Git 状态和 remotes。
3. 搜索品牌入口。
4. 识别内部兼容标识。
5. 运行或记录基线测试。
6. 输出文件级改造计划。

此阶段不修改代码。

### 阶段 B：建立分支和品牌矩阵

AI 必须明确：

- 哪些名称要改。
- 哪些名称必须保留。
- Logo 源文件和派生尺寸。
- 新 App ID。
- 法律主体信息。
- 私有部署和更新策略。

### 阶段 C：分层实现

推荐顺序：

1. Logo 资源。
2. 首屏和可见文案。
3. Electron/Tauri 产品身份。
4. Windows PE 元数据。
5. 安装器和快捷方式。
6. 隔离启动器。
7. 测试和 CI。

每一层完成后立即做局部验证。

### 阶段 D：打包和本机部署

AI 必须完成：

1. 生产构建。
2. unpacked 打包。
3. 正式安装包。
4. PE 元数据检查。
5. 独立目录安装。
6. 启动器和快捷方式。
7. UI 与后端 smoke test。

### 阶段 E：交付报告

最终报告必须包含：

- 改动文件和改动范围。
- 保留的内部兼容标识。
- 生成的 exe 和安装包路径。
- 测试结果。
- 本机安装路径。
- 启动方式。
- 已知问题和限制。
- Git commit 和远端状态。

## 13. 可直接复制给 AI 的任务模板

```text
请对当前仓库执行“ZhiyanFlow 轻量二开换标”。

目标：
1. 用户可见产品名统一为 ZhiyanFlow。
2. 首屏、窗口、About、安装器和更新文案统一换标。
3. 主程序文件名改为 ZhiyanFlow.exe。
4. Windows exe、任务栏、快捷方式和安装器使用我提供的智研 Logo。
5. Windows PE ProductName 和 FileDescription 改为 ZhiyanFlow。
6. App ID 使用 com.zhiyanwanwu.zhiyanflow。
7. 桌面、开始菜单和卸载项统一显示 ZhiyanFlow。
8. 如果界面存在右下角版本号，只隐藏 UI，不删除版本元数据。
9. 使用独立的 %LOCALAPPDATA%\ZhiyanFlow 数据目录。
10. 最终在本机安装并可通过桌面图标启动。

兼容边界：
- 保留原 npm/Python/Rust 包名。
- 保留原 CLI 命令。
- 保留原 URL scheme。
- 保留原环境变量前缀、IPC channel、存储键和后端目录结构。
- 保留原作者和许可证；未提供新法律主体前，不修改 CompanyName 和版权主体。
- 禁止全仓库无脑替换原产品名。
- 禁止把 GitHub Token 写入源码、脚本、remote URL 或安装包。

仓库要求：
- origin 指向智研私有仓库。
- upstream 指向官方仓库并禁止推送。
- 在独立 branding 分支实施。
- 先判断是否存在共同祖先；没有共同祖先时禁止强行合并 upstream/main。

执行顺序：
1. 先只读审计并给出文件级计划。
2. 经确认后实施 Logo、UI、桌面身份、PE、安装器和启动器改造。
3. 执行 lint、类型检查、聚焦测试、生产构建和 Windows 打包。
4. 检查最终 exe 和安装包元数据。
5. 使用独立数据目录做本机 smoke test。
6. 提交到私有仓库并给出完整验收报告。

验收重点：
- ZhiyanFlow.exe 可运行。
- 图标和产品名一致。
- 首屏显示 ZhiyanFlow。
- 不显示被要求隐藏的版本号。
- 后端正常启动。
- 不访问不存在于官方仓库的私有 commit raw URL。
- 不影响原产品的安装和数据。
```

## 14. 每个新项目的开工填空表

```text
原项目名称：Ragflow
原项目仓库：https://github.com/infiniflow/ragflow
智研私有仓库：https://github.com/zhiyanwanwu/ZhiyanFlow
目标产品名称：ZhiyanFlow
目标 App ID：com.zhiyanwanwu.zhiyanflow
目标 exe 名称：ZhiyanFlow.exe
Logo 文件路径：
法律主体：
目标平台：Windows / macOS / Linux / Web
桌面框架：
安装器类型：
原 CLI 命令：
原协议 scheme：
原数据目录：
新的独立数据目录：%LOCALAPPDATA%\ZhiyanFlow
首次启动方式：
自动更新来源：
必须隐藏的 UI：
必须保留的兼容标识：
本机验收机器：
```

## 15. 最终交付物

一个合格的 `ZhiyanFlow` 换标项目应交付：

1. 源码审计报告。
2. 品牌替换矩阵。
3. Logo 源文件和各平台派生资源。
4. 已提交的换标源码。
5. `ZhiyanFlow.exe` unpacked 产物。
6. Windows 正式安装包。
7. 隔离部署目录和启动脚本。
8. 桌面与开始菜单快捷方式。
9. 测试和构建结果。
10. 本机 smoke test 记录。
11. 已知问题清单。
12. 私有仓库 commit 和分支信息。

只有“网页上看起来换了 Logo”不算完成。必须从源码、构建、安装、系统身份、运行时兼容和本机部署六个层面全部验收。
