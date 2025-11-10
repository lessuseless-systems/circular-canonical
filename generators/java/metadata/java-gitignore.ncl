# Java .gitignore Generator
# Generates comprehensive .gitignore for Java Maven projects

let config = import "../../../src/config.ncl" in

{
  gitignore_content = m%"
# Java .gitignore
# Generated from Nickel specifications

# Compiled class files
*.class

# Log files
*.log

# BlueJ files
*.ctxt

# Mobile Tools for Java (J2ME)
.mtj.tmp/

# Package Files
*.jar
*.war
*.nar
*.ear
*.zip
*.tar.gz
*.rar

# Virtual machine crash logs
hs_err_pid*
replay_pid*

# Maven
target/
pom.xml.tag
pom.xml.releaseBackup
pom.xml.versionsBackup
pom.xml.next
release.properties
dependency-reduced-pom.xml
buildNumber.properties
.mvn/timing.properties
.mvn/wrapper/maven-wrapper.jar

# Gradle
.gradle
**/build/
!src/**/build/
gradle-app.setting
!gradle-wrapper.jar
!gradle-wrapper.properties
.gradletasknamecache

# Eclipse
.classpath
.project
.settings/
bin/
tmp/
*.tmp
*.bak
*.swp
*~.nib
local.properties
.loadpath
.recommenders

# IntelliJ IDEA
.idea/
*.iws
*.iml
*.ipr
out/

# NetBeans
/nbproject/private/
/nbbuild/
/dist/
/nbdist/
/.nb-gradle/

# VS Code
.vscode/
*.code-workspace

# macOS
.DS_Store
.AppleDouble
.LSOverride
._*

# Windows
Thumbs.db
Thumbs.db:encryptable
ehthumbs.db
ehthumbs_vista.db
*.stackdump
[Dd]esktop.ini

# Linux
*~
.fuse_hidden*
.directory
.Trash-*
.nfs*

# Temporary files
*.tmp
*.temp

# Test output
test-output/
*.log

# JUnit
.junit/
"%,
}
