plugins {
    kotlin("jvm")
}


dependencies {
   implementation(project(":domain"))
}


kotlin {
    jvmToolchain(21)
}