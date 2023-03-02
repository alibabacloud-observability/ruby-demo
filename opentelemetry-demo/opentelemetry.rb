require 'opentelemetry/sdk'
require 'opentelemetry-exporter-otlp'

OpenTelemetry::SDK.configure do |c|
  c.add_span_processor(
    OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
      OpenTelemetry::Exporter::OTLP::Exporter.new(
        endpoint: '<endpoint>' # http方式接入
      )
    )
  )
  c.resource = OpenTelemetry::SDK::Resources::Resource.create({
    OpenTelemetry::SemanticConventions::Resource::SERVICE_NAMESPACE => 'tracing',
    OpenTelemetry::SemanticConventions::Resource::SERVICE_NAME => 'ruby_demo', # 通过OpenTelemetry上报的Ruby应用名
    OpenTelemetry::SemanticConventions::Resource::SERVICE_VERSION => '0.0.1',
  })

  # 不使用OpenTelemetry Resources API来设置应用名
  # c.service_name = 'ruby_demo'
end

tracer = OpenTelemetry.tracer_provider.tracer('instrumentation_library_name', '0.1.0')

tracer.in_span('parent_span') do |parent_span|
  # 设置 Attribute
  parent_span.set_attribute('language', 'ruby')
  parent_span.set_attribute("attribute_key", ["attribute_value1", "attribute_value1", "attribute_value1"])
  # 添加 Event
  parent_span.add_event("event", attributes: {
    "pid" => 1234,
    "signal" => "SIGHUP"
  })

  # 获取Trace ID与当前Span的Span ID
  current_span = OpenTelemetry::Trace::current_span
  pp current_span.context.trace_id
  pp current_span.context.span_id

  tracer.in_span('child_span') do |child_span|
    child_span.add_attributes({
      "key1" => "value1",
      "key2" => "value2"
    })

    child_span.add_event("mock exception here")

    begin
      raise 'An error has occurred'
    rescue
      # 发生异常时为 child_span 设置 status
      child_span.status = OpenTelemetry::Trace::Status.error("error in child span")
    end

    pp child_span

  end
end

sleep 10