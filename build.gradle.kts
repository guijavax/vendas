plugins {
	kotlin("jvm") version "1.9.24" apply false
	id("org.springframework.boot") version "3.3.3" apply false
	id("io.spring.dependency-management") version "1.1.6" apply false
	jacoco
}

group = "br.om"
version = "0.0.1-SNAPSHOT"
description = "Demo project for Spring Boot"

val javaVersion = "21"


subprojects {
	repositories { mavenCentral() }
}

jacoco { toolVersion = "0.8.11" }