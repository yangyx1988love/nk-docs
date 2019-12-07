
---
title: "类加载流程"
weight: 200
description: >
  主要介绍本系统jersey相关类的大致加载流程。
---

## 一、程序入口RestDBApplication
Springboot的启动程序入口

    @SpringBootApplication
    //整合swagger
    @EnableSwagger2
    public class RestDBApplication {
       private static final Logger logger = LoggerFactory
             .getLogger(RestDBApplication.class);
    
       public static void main(String[] args) {
          logger.info("application is ready to start...");
          SpringApplication.run(RestDBApplication.class, args);
          logger.info("application started successfully.");
       }
    }
## 二、配置spring并启动spring容器，注册servlet容器ServletRegistrationBean

    @Configuration
    public class JerseyServletConfiguration {
       @Bean
       @Autowired
       public ServletRegistrationBean<JerseyResourceServletContainer> jerseyServlet(
             JerseyResourceConfigProperties properties,
             DocumentationPluginsBootstrapper springfox,
             SpringfoxModelsProvider models) {
          ServletRegistrationBean<JerseyResourceServletContainer> bean = new ServletRegistrationBean<JerseyResourceServletContainer>(
                new JerseyResourceServletContainer(properties, springfox, models),
                properties.resourceUrlPrefix + "/*");
          bean.setLoadOnStartup(1);
          return bean;
       }
    }
####  其中JerseyResourceConfigProperties类通过application.properties获取资源配置
    @Component
    @ConfigurationProperties(prefix = "jersey")
    public class JerseyResourceConfigProperties {
       @Value("${jersey.resources.configFolder}")
       public String resourceConfigFolder;
       @Value("${jersey.resources.urlPrefix}")
       public String resourceUrlPrefix;
       @Value("${jersey.resources.configWatch}")
       public Boolean watchResourceFolder;
       public Map<String, String> apiConfig;
       public Map<String, Map<String, Object>> datasources;
       public Map<String, Object> defaults;
       public void setSwagger(Map<String, String> apiConfig) {
          this.apiConfig = apiConfig;
       }   
       public void setDatasources(Map<String, Map<String, Object>> ds) {
          this.datasources = ds;
       } 
       public void setDefault(Map<String, Object> defaults) {
          this.defaults = defaults;
       }
    }
    
>下图中properties为本系统中根据application.properties配置文件获取的属性值

![](../img_resrdb_process/process_01.png)
## 三、	资源执行器，接受资源配置
JerseyResourceServletContainer继承了org.glassfish.jersey.servlet. ServletContainer，配置Servlet容器；
传入DocumentationPluginsBootstrapper springfox,SpringfoxModelsProvider models参数，配置并启动springfox

#### 传入参数

![](../img_resrdb_process/process_02.png)
    
#### 调用buildConfiguration，配置ResourceConfig

Jersey提供了org.glassfish.jersey.server.ResourceConfig类来简化我们的操作。ResourceConfig类是Jersey自己实现了Application，并且还实现了Configuration接口。
ResourceConfig类提供了非常多的方法来注册JAX-RS组件，比如自动的资源类扫描就是其提供的众多功能之一。

####传入参数 其中ResourceConfig original首次加载时为null
![](../img_resrdb_process/process_03.png)

    // 构建数据访问对象映射: daoConfig
    if (_daoConfig == null) {
        _daoConfig = JerseyResourceConfigUtilities.buildDaoConfig(
                (Map<String, Map<String, Object>>) properties.datasources);
    }
    //获取所有资源集文件
    File folder = new File(properties.resourceConfigFolder);
    final int folderPathLength = folder.getAbsolutePath().length() + 1;
    Iterator<File> it = FileUtils.iterateFiles(folder,
            new String[] { "yaml" }, true);
>各参数运行时value如下
         
![](../img_resrdb_process/process_04.png)        

#### 枚举资源配置目录，通过JerseyResourceSetBuilder.build方法获取资源集resourceSet

    while (it.hasNext()) {
        File file = it.next();

        // 加载 yaml 配置
        Map<String, Object> yamlConfig = JerseyResourceConfigUtilities
                .loadYamlResourceConfig(file, folderPathLength);

        if (yamlConfig != null) {
            _log.info("***** {} resources in file {}",
                    //original == null为初次加载
                    original == null ? "Load" : "Reload",
                    file.getAbsolutePath().substring(folderPathLength));

            String resBasePath = "/" + file.getAbsolutePath()
                    .substring(folderPathLength,
                            file.getAbsolutePath().lastIndexOf("."))
                    .replace('\\', '/');

            // 根据 yaml 配置构建资源集
            Set<Resource> resources = JerseyResourceSetBuilder.build(
                    resBasePath, ImmutableMap.copyOf(yamlConfig), _daoConfig,
                    ImmutableMap.copyOf(properties.defaults));

            resourceSet.addAll(resources);
        }
    }
    
![](../img_resrdb_process/process_05.png)     
    

#### JerseyResourceSetBuilder.build
    
Set<Resource> resources = JerseyResourceSetBuilder.build(resBasePath, ImmutableMap.copyOf(yamlConfig), _daoConfig,
ImmutableMap.copyOf(properties.defaults));

+ resBasePath//资源访问根路径

+ ImmutableMap.copyOf(yamlConfig)//通过yaml获取该文件中resource资源属性，ImmutableMap不可修改

+ _daoConfig//通过JerseyResourceConfigUtilities.buildDaoConfig((Map<String, Map<String, Object>>) properties.datasources)方法构造数据访问映射对象

+ ImmutableMap.copyOf(properties.defaults))//默认属性

         
![](../img_resrdb_process/process_06.png)     
    
#### 根据资源描述，逐个构建资源

    Set<Resource> resources = new HashSet<Resource>();
    //获取resources标签下的resource属性
    List<Map<String, Object>> resourceDescriptions = (List<Map<String, Object>>) resourceConfig
            .get("resources");

    JerseyResourceSetBuilder builder = new JerseyResourceSetBuilder(
            resBasePath, daoConfig, defaults);

    for (Map<String, Object> description : resourceDescriptions) {
        try {
            //通过buildResource方法，配置resourceDescription
            resources.add(builder.buildResource(description));
        } catch (Exception e) {
            _log.error("Fail to build resource", e);
        }
    }

![](../img_resrdb_process/process_07.png)     
   
#### 利用JerseyResourceInflector构建请求类
    
    Inflector<ContainerRequestContext, Object> inflector = JerseyResourceInflector
    				.build(preTasks, tasks, postTasks, description, _daoConfig);
    				
![](../img_resrdb_process/process_08.png)   
     
#### buildActions，根据请求类型生成不同类型（sql、python、Java）的请求类

	static public void buildActions(List<Map<String, Object>> tasks,
			Map<String, Object> context, Map<String, NutDao> datasources,
			List<JerseyResourceAction> actions) throws Exception {
		if (tasks == null) {
			return;
		}
		for (Map<String, Object> task : tasks) {
			String type = (String) task.get("type");
			JerseyResourceAction action = JerseyResourceActionProvider
					.build(type);
			if (action == null) {
				throw new Exception("Fail to create action of type: " + type);
			}
			actions.add(action);
		}
	} 				
    
    public interface JerseyResourceActionProvider {
       JerseyResourceAction createAction(String type);
       //ServiceLoader.load 根据传入的接口类，遍历META-INF/services目录下的以该类命名的文件中的所有类，并实例化返回
       //本项目中这三个方法均实现了JerseyResourceActionProvider接口
       static ServiceLoader<JerseyResourceActionProvider> _loader = ServiceLoader
             .load(JerseyResourceActionProvider.class);
    
       static JerseyResourceAction build(String type) throws Exception {
          for (JerseyResourceActionProvider provider : _loader) {
             JerseyResourceAction action = provider.createAction(type);
             if (action != null) {
                return action;
             }
          }
    
          throw new Exception("Fail to create action of type '" + type + "'");
       }
    }
    
#### type为null时，则默认为sql

    public class JerseyResourceSqlActionProvider
          implements JerseyResourceActionProvider {
    
       @Override
       public JerseyResourceAction createAction(String type) {
          if (type == null || "sql".equalsIgnoreCase(type)) {
             return new JerseyResourceActionImpl();
          }
          return null;
       }

#### JerseyResourceSetBuilder.builde()方法执行完成，返回resources集合

![](../img_resrdb_process/process_09.png)   

#### JerseyResourceServletContainer.buildConfiguration()方法执行完成，实现对ResourceConfig的注册

![](../img_resrdb_process/process_10.png)   

最后bean 'jerseyServlet' of class org.springframework.boot.web.servlet.ServletRegistrationBean initialized

## 四、文件监听
資源配置改變觀察器。當資源配置文件修改時，自動重新啟動容器
JerseyResourceConfigWatcher
通过调用JerseyResourceServletContainer的reload方法实现重载

    @Override
    public void reload() {
       // 重新构建 springfox 文档
       _springfox.stop();
       
       try {
          Field field = SpringfoxModelsProvider.class.getDeclaredField("_models");
          field.setAccessible(true);
          @SuppressWarnings("unchecked")
          List<ResolvedType> list = (List<ResolvedType>)field.get(_models);
          list.clear();
       } catch (IllegalArgumentException | IllegalAccessException | NoSuchFieldException | SecurityException e) {
          _log.error("Fail to clear existing models");
       }
       
       _springfox.start();
       
       // 重新加载 jersey 资源集合
       reload(buildConfiguration(_properties, getConfiguration()));
    }

  