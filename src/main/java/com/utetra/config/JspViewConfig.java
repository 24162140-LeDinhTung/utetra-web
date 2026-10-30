package com.utetra.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.view.InternalResourceViewResolver;
import org.springframework.web.servlet.view.JstlView;

@Configuration
public class JspViewConfig {
  @Bean
  public InternalResourceViewResolver defaultViewResolver() {
    InternalResourceViewResolver resolver = new InternalResourceViewResolver();
    resolver.setViewClass(JstlView.class);
    // Included JSPs cannot change the response charset set by the view.
    resolver.setContentType("text/html;charset=UTF-8");
    resolver.setPrefix("/WEB-INF/views/");
    resolver.setSuffix(".jsp");
    // Tomcat 11 forward() unwraps the response buffer used by SiteMesh.
    resolver.setAlwaysInclude(true);
    return resolver;
  }
}
