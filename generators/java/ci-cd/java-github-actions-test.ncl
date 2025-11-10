# GitHub Actions CI/CD Generator for Java
# Generates .github/workflows/test.yml for automated testing and publishing

let config = import "../../../src/config.ncl" in

let workflow = {
  name = "Test and Build",

  on = {
    push = {
      branches = ["main", "development"],
    },
    pull_request = {
      branches = ["main", "development"],
    },
  },

  jobs = {
    test = {
      "runs-on" = "ubuntu-latest",

      strategy = {
        matrix = {
          "java-version" = ["11", "17", "21"],
        },
      },

      steps = [
        {
          name = "Checkout code",
          uses = "actions/checkout@v4",
        },
        {
          name = "Setup Java ${{ matrix.java-version }}",
          uses = "actions/setup-java@v4",
          "with" = {
            "java-version" = "${{ matrix.java-version }}",
            distribution = "temurin",
            cache = "maven",
          },
        },
        {
          name = "Build with Maven",
          run = "mvn clean compile",
        },
        {
          name = "Run tests",
          run = "mvn test",
        },
        {
          name = "Package",
          run = "mvn package -DskipTests",
        },
        {
          name = "Verify package",
          run = "mvn verify -DskipTests",
        },
      ],
    },

    publish-snapshot = {
      "runs-on" = "ubuntu-latest",
      needs = "test",
      "if" = "github.ref == 'refs/heads/development' && github.event_name == 'push'",

      steps = [
        {
          name = "Checkout code",
          uses = "actions/checkout@v4",
        },
        {
          name = "Setup Java",
          uses = "actions/setup-java@v4",
          "with" = {
            "java-version" = "17",
            distribution = "temurin",
            cache = "maven",
            "server-id" = "ossrh",
            "server-username" = "MAVEN_USERNAME",
            "server-password" = "MAVEN_PASSWORD",
            "gpg-private-key" = "${{ secrets.GPG_PRIVATE_KEY }}",
            "gpg-passphrase" = "GPG_PASSPHRASE",
          },
        },
        {
          name = "Build package",
          run = "mvn clean package -DskipTests",
        },
        {
          name = "Deploy snapshot to OSSRH",
          run = "mvn deploy -DskipTests",
          env = {
            MAVEN_USERNAME = "${{ secrets.OSSRH_USERNAME }}",
            MAVEN_PASSWORD = "${{ secrets.OSSRH_PASSWORD }}",
            GPG_PASSPHRASE = "${{ secrets.GPG_PASSPHRASE }}",
          },
          continue-on-error = true,
        },
      ],
    },

    publish-release = {
      "runs-on" = "ubuntu-latest",
      needs = "test",
      "if" = "github.ref == 'refs/heads/main' && github.event_name == 'push'",

      steps = [
        {
          name = "Checkout code",
          uses = "actions/checkout@v4",
        },
        {
          name = "Setup Java",
          uses = "actions/setup-java@v4",
          "with" = {
            "java-version" = "17",
            distribution = "temurin",
            cache = "maven",
            "server-id" = "ossrh",
            "server-username" = "MAVEN_USERNAME",
            "server-password" = "MAVEN_PASSWORD",
            "gpg-private-key" = "${{ secrets.GPG_PRIVATE_KEY }}",
            "gpg-passphrase" = "GPG_PASSPHRASE",
          },
        },
        {
          name = "Build and sign package",
          run = "mvn clean package -Prelease",
        },
        {
          name = "Deploy release to Maven Central",
          run = "mvn deploy -Prelease -DskipTests",
          env = {
            MAVEN_USERNAME = "${{ secrets.OSSRH_USERNAME }}",
            MAVEN_PASSWORD = "${{ secrets.OSSRH_PASSWORD }}",
            GPG_PASSPHRASE = "${{ secrets.GPG_PASSPHRASE }}",
          },
        },
      ],
    },
  },
} in

{
  workflow_yaml = std.serialize 'Yaml workflow,
}
