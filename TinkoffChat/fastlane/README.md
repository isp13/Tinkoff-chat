fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
### build_for_testing
```
fastlane build_for_testing
```
установка зависимостей, сборка с помощью scan
### run_tests
```
fastlane run_tests
```
запуск тестов на уже скомпилированном приложении
### build_and_test
```
fastlane build_and_test
```
вызов первых двух лейнов(сборка и тестирование)
### discordSuccess
```
fastlane discordSuccess
```
отправка уведомления в Discord - Success
### discordFailure
```
fastlane discordFailure
```
отправка уведомления в Discord - Failure

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
