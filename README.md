## 通过OpenTelemetry上报Ruby应用数据

### 方法一：通过OpenTelemetry Ruby SDK手动埋点
1. 请先安装手动埋点所需的OpenTelemetry相关依赖：
```
gem install opentelemetry-api
gem install opentelemetry-sdk
gem install opentelemetry-exporter-otlp
```

2. 修改manual.rb文件中的endpoint、SERVICE_NAMESPACE、SERVICE_NAME、SERVICE_VERSION

3. 运行：`ruby manual.rb`


### 方法二：使用OpenTelemetry自动埋点

OpenTelemetry Ruby也可以自动在应用程序中埋点，实现自动观测。下面以基于Rails框架的Ruby Web应用为例，使用OpenTelemetry自动追踪链路并上报数据。

1. 下载开源Web应用框架 Rails： `gem install rails`

2. 使用Rails创建Web项目：`rails new <your-project-name>`
- 请将` <your-project-name>` 替换为你的应用名，例如 `rails new auto-demo`

- 如果运行命令后出现 `Rails is not currently installed on this system.` 的报错，请关掉你的终端并重新打开，然后在新终端中重新输入命令。

3.  在 <your-project-name> 目录下的Gemfile中添加以下内容：

```
gem 'opentelemetry-sdk'
gem 'opentelemetry-exporter-otlp'
gem 'opentelemetry-instrumentation-all'
```

4. 下载此Web应用所需的第三方依赖：
- 进入项目根目录：`cd <your-project-name>`
- 下载Ruby依赖管理工具bundler：`gem install bundler`
- 执行命令，下载Gemfile中的依赖： `bundle install`

5. 在`<your-project-name>/config/initializers`目录下创建 opentelemetry.rb 文件，添加如下内容
- 请替换`<endpoint>`,`<your-host-name>`和`<your-service-name>`

```
# config/initializers/opentelemetry.rb
require 'opentelemetry/sdk'
require 'opentelemetry/exporter/otlp'
require 'opentelemetry/instrumentation/all'

OpenTelemetry::SDK.configure do |c|
  c.add_span_processor(
    OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
      OpenTelemetry::Exporter::OTLP::Exporter.new(
        endpoint: '<endpoint>' # http方式接入
      )
    )
  )
  c.resource = OpenTelemetry::SDK::Resources::Resource.create({
    OpenTelemetry::SemanticConventions::Resource::HOST_NAME => '<your-host-name>', # 主机名
  })
  c.service_name = '<your-service-name>' # 服务名
  c.use_all() # 自动观测opentelemetry支持的所有库，
end
```

6. 运行项目：`rails server`
- 如果输出以下内容，则代表运行成功
```
* Puma version: 5.6.5 (ruby 2.7.2-p137) ("Birdie's Version")
*  Min threads: 5
*  Max threads: 5
*  Environment: development
*          PID: 79842
* Listening on http://127.0.0.1:3000
* Listening on http://[::1]:3000
Use Ctrl-C to stop
```


7. 在浏览器访问 `http://127.0.0.1:3000`，此时终端会输出以下内容。此时可登录链路追踪控制台查看Trace数据上报情况。
```
Started GET "/" for 127.0.0.1 at 2023-01-01 00:10:00 +0800
Processing by Rails::WelcomeController#index as HTML
  Rendering /Users/username/.rvm/gems/ruby-2.7.2/gems/railties-7.0.4.3/lib/rails/templates/rails/welcome/index.html.erb
  Rendered /Users/username/.rvm/gems/ruby-2.7.2/gems/railties-7.0.4.3/lib/rails/templates/rails/welcome/index.html.erb (Duration: 0.8ms | Allocations: 665)
Completed 200 OK in 6ms (Views: 2.1ms | ActiveRecord: 0.0ms | Allocations: 5440)
```
