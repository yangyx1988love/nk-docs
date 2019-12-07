
---
title: "SpringBox"
weight: 200
description: >
  本系统的API是由SpringBox框架管理，为前台提供详细的API信息。
---

## 一、认识Swagger（https://swagger.io/docs/specification/basic-structure/）

    Swagger 是一个规范和完整的框架，用于生成、描述、调用和可视化 RESTful 风格的 Web 服务。
    总体目标是使客户端和文件系统作为服务器以同样的速度来更新。文件的方法，参数和模型紧密
    集成到服务器端的代码，允许API来始终保持同步。

#### 开源工具

    现在SWAGGER官网主要提供了几种开源工具，提供相应的功能。可以通过配置甚至是修改源码以达到你想要的效果
    
![](../img_springBox/sringBox-01.png)

> Swagger Codegen 

    通过Codegen 可以将描述文件生成html格式和cwiki形式的接口文档，同时也能生成多钟语言的服务端和客户端的
    代码。支持通过jar包，docker，node等方式在本地化执行生成。也可以在后面的Swagger Editor中在线生成。

> Swagger UI

    提供了一个可视化的UI页面展示描述文件。接口的调用方、测试、项目经理等都可以在该页面中对相关接口进行查阅
    和做一些简单的接口请求。该项目支持在线导入描述文件和本地部署UI项目。

> Swagger Editor
 
    类似于markendown编辑器的编辑Swagger描述文件的编辑器，该编辑支持实时预览描述文件的更新效果。也提供了在
    线编辑器和本地部署编辑器两种方式。

> Swagger Inspector 
 
    感觉和postman差不多，是一个可以对接口进行测试的在线版的postman。比在Swagger UI里面做接口请求，会返
    回更多的信息，也会保存你请求的实际请求参数等数据。
    
    

> Swagger Hub
    
    集成了上面所有项目的各个功能，你可以以项目和版本为单位，将你的描述文件上传到Swagger Hub中。在Swagger Hub
    中可以完成上面项目的所有工作，需要注册账号，分免费版和收费版。
    
> 使用教材，参照如下博客
    https://blog.csdn.net/rth362147773/article/details/78992043
    
    
## 二、SpringBox

    Spring框架迅充分利用自已的优势，把swagger集成到自己的项目里，整了一个spring-swagger，后来便演变
    成springfox。springfox本身只是利用自身的aop的特点，通过plug的方式把swagger集成了进来，它本身对业务api的
    生成，还是依靠swagger来实现。

> 1、依赖

        <!-- swagger2核心依赖 -->
		<dependency>
			<groupId>io.springfox</groupId>
			<artifactId>springfox-swagger2</artifactId>
			<version>2.9.2</version>
		</dependency>
		 <!-- swagger-ui为项目提供api展示及测试的界面 -->
		<dependency>
			<groupId>io.springfox</groupId>
			<artifactId>springfox-swagger-ui</artifactId>
			<version>2.9.2</version>
		</dependency>
		    
> 2、流程

![](../img_springBox/sringBox-02.png)

#### API详细说明
![](../img_springBox/sringBox-03.png)

    - @Api()用于类；
    表示标识这个类是swagger的资源
    - @ApiOperation()用于方法；
    表示一个http请求的操作
    - @ApiParam()用于方法，参数，字段说明；
    表示对参数的添加元数据（说明或是否必填等）
    - @ApiModel()用于类
    表示对类进行说明，用于参数用实体类接收
    - @ApiModelProperty()用于方法，字段
    表示对model属性的说明或者数据操作更改
    - @ApiIgnore()用于类，方法，方法参数
    表示这个方法或者类被忽略
    - @ApiImplicitParam() 用于方法
    表示单独的请求参数
    - @ApiImplicitParams() 用于方法，包含多个 @ApiImplicitParam
    
> 1、@Api
    
    Api 用在类上，说明该类的作用。可以标记一个Controller类做为swagger 文档资源，使用方式：
    @Api(value = "/user", description = "Operations about user") 
![](../img_springBox/sringBox-04.png)

>2、@ApiOperation

    ApiOperation：用在方法上，说明方法的作用，每一个url资源的定义,使用方式：
    @ApiOperation(
     value = "Find purchase order by ID",
     notes = "For valid response try integer IDs with value <= 5 or > 10. Other values will generated exceptions",
     response = Order,
     tags = {"Pet Store"}
    )
![](../img_springBox/sringBox-05.png)

>3、@ApiParam

    public ResponseEntity<User> createUser(@RequestBody @ApiParam(value = "Created user object", 
    required = true)  User user)
    
![](../img_springBox/sringBox-06.png)

> 4、ApiImplicitParam

![](../img_springBox/sringBox-08.png)

>5、ApiResponse

    ApiResponse：响应配置，使用方式： 
    @ApiResponse(code = 400, message = "Invalid user supplied") 
![](../img_springBox/sringBox-07.png)

>6、ApiResponses

    ApiResponses：响应集配置，使用方式： 
    @ApiResponses({ @ApiResponse(code = 400, message = "Invalid Order") }) 

>7、ResponseHeader

    响应头设置，使用方法 
    @ResponseHeader(name="head1",description="response head conf") 
![](../img_springBox/sringBox-09.png)

## 三、SpringBox与SporingBoot的整合

> 1、配置Swagger

	//docket容器设置我们的文档基础信息，api包的位置，以及路劲的匹配规则（包含四种：全匹配，不匹配，正则匹配和ant匹配）
	public Docket springfoxDocket(
			@Autowired JerseyResourceConfigProperties properties) {

		// 文档构建起点为 DocumentationPluginsBootstrapper
		//通过JerseyResourceConfigProperties类获取appication配置文件swagger属性配置
		final String prefix = properties.resourceUrlPrefix + "/";
		Map<String, String> apiConfig = properties.apiConfig;

		//apiInfo对象主要是设置我们api文档的标题，描述，访问的地址，创建者等信息
		ApiInfo apiInfo = new ApiInfo(apiConfig.get("title"),
				apiConfig.get("description"), apiConfig.get("version"),
				apiConfig.get("termsOfServiceUrl"),
				new Contact(apiConfig.get("contactName"),
						apiConfig.get("contactUrl"),
						apiConfig.get("contactEmail")),
				apiConfig.get("license"), apiConfig.get("licenseUrl"),
				new ArrayList<VendorExtension>());

		List<ResponseMessage> responseMessageList = new ArrayList<>();
		responseMessageList.add(
				new ResponseMessageBuilder().code(200).message("OK").build());

		return new Docket(DocumentationType.SWAGGER_2).apiInfo(apiInfo).select()
				.paths(new Predicate<String>() {
					@Override
					public boolean apply(String input) {
						return input.startsWith(prefix);
					}
				}).build()
				.globalResponseMessage(RequestMethod.GET, responseMessageList)
				.globalResponseMessage(RequestMethod.POST, responseMessageList)
				.globalResponseMessage(RequestMethod.PUT, responseMessageList)
				.globalResponseMessage(RequestMethod.DELETE,
						responseMessageList);
	}

> 2.yaml编写（http://editor.swagger.io/#/）

    swagger: '2.0'                      # swagger的版本
    info:
      title: 文档标题
      description:  描述
      version: "v1.0"                   # 版本号
      termsOfService: ""                # 文档支持截止日期
      contact:                          # 联系人的信息
        name: ""                        # 联系人姓名
        url: ""                         # 联系人URL
        email: ""                       # 联系人邮箱
      license:                          # 授权信息
        name: ""                        # 授权名称，例如Apache 2.0
        url: ""                         # 授权URL
    host: api.haofly.net                # 域名，可以包含端口，如果不提供host，那么默认为提供yaml文件的host
    basePath: /                         # 前缀，比如/v1
    schemes:                            # 传输协议
      - http
      - https
    
    securityDefinitions:                # 安全设置
      api_key:
        type: apiKey
        name: Authorization             # 实际的变量名比如，Authorization
        in: header                      # 认证变量放在哪里，query或者header
      OauthSecurity:                    # oauth2的话有些参数必须写全
        type: oauth2
        flow: accessCode                # 可选值为implicit/password/application/accessCode
        authorizationUrl: 'https://oauth.simple.api/authorization'
        tokenUrl: 'https://oauth.simple.api/token'
        scopes:
          admin: Admin scope
          user: User scope
          media: Media scope
      auth:
        type: oauth2
        description: ""                 # 描述
        authorizationUrl: http://haofly.net/api/oauth/
        name: Authorization             # 实际的变量名比如，Authorization
        tokenUrl:
        flow: implicit                  # oauth2认证的几种形式，implicit/password/application/accessCode
        scopes:
          write:post: 修改文件
          read:post: 读取文章
    
    security:                           # 全局的安全设置的一个选择吧
      auth:
        - write:pets
        - read:pets
    
    consumes:                           # 接收的MIME types列表
      - application/json                # 接收响应的Content-Type
      - application/vnd.github.v3+json
    
    produces:                           # 请求的MIME types列表
      - application/vnd.knight.v1+json  # 请求头的Accept值
      - text/plain; charset=utf-8
    tags:                               # 相当于一个分类
      - name: post  
        description: 关于post的接口
    
    externalDocs:
      description: find more info here
      url: https://haofly.net
    
    paths:                              # 定义接口的url的详细信息
      /projects/{projectName}:          # 接口后缀，可以定义参数
        get:
          tags:                         # 所属分类的列表
            - post  
          summary: 接口描述              # 简介
          description:                  # 详细介绍
          externalDocs:                 # 这里也可以加这个
            description:
            url:
          operationId: ""               # 操作的唯一ID
          consumes: [string]            # 可接收的mime type列表
          produces: [string]            # 可发送的mime type列表
          schemes: [string]             # 可接收的协议列表
          deprecated: false             # 该接口是否已经弃用
          security:                     # OAuth2认证用
            - auth: 
                - write:post
                - read: read
          parameters:                   # 接口的参数
            - name: projectName         # 参数名
              in: path                  # 该参数应该在哪个地方，例如path、body、query等，但是需要注意的是如果in body，只能用schema来指向一个定义好的object，而不能直接在这里定义
              type: string              # 参数类型
              allowEmptyValue: boolean          # 是否允许为空值
              description: 项目名        # 参数描述
              required: true            # 是否必须
              default: *                # 设置默认值
              maximum: number           # number的最大值
              exclusiveMaximum: boolean # 是否排除最大的那个值
              minimum: number           # number的最小值
              exclusiveMinimum: boolean
              maxLength: integer        # int的最大值
              minLength: integer
              enum: [*]                 # 枚举值
              items:                    # type为数组的时候可以定义其项目的类型
            - $ref: "#/parameters/uuidParam"   # 这样可以直接用定义好的
          responses:                    # 设置响应
            200:                        # 通过http状态来描述响应
              description: Success      # 该响应的描述
              schema:                   # 定义返回数据的结构
                $ref: '#/definitions/ProjectDataResponse'  # 直接关联至某个model
    
      /another: # 另一个接口
          responses:
            200:
                description:
                schema:
                  type: object
                  properitis:
                    data:
                        $ref: '#/definitions/User' # 关联
    
    definitions:            # Model/Response的定义，这里的定义不强制要求返回数据必须和这个一致，但是在swagger-ui上，会展示这里面的字段。
      Product:              # 定义一个model
        type: object        # model类型
        properties:         # 字段列表
          product_id:       # 字段名
            type: integer   # 字段类型
            description:    # 字段描述
          product_name:
            type: string
            description: 
      ProjectDataResponse:
        type: object
        properties:
            data:
                $ref: '#/definitions/ProjectResponse'  # model之间的关联，表示在data字段里面包含的是一个ProjectResponse对象
    parameters:             # 可以供很多接口使用的params
      limitParam:
        name: limit
        in: query
        description: max records to return
        required: true
        type: integer
        format: int32
    responses:              # 可以供很多接口使用的responses
      NotFound:
        description: Entity not found.
