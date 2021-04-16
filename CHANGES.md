### 2.2.3 - 2021/04/16

* Fix a possible initialization problem with Watir 7.0.0+. See #32.
 
### 2.2.2 - 2020/06/04

* Fix a situation where checking if server is running without using specified port. PR #27 by Stefan Rotariu.

### 2.2.1 - 2019/05/12

* Fix EOFError on some environments. PR #25 by Slava Kardakov.

### 2.2.0 - 2019/05/08

* Add support for specifying custom server for test Rails instance. PR #23 by Alex Rodionov.
* Add support for cleaning up when test Rails server instance has served all requests. PR #23 by Alex Rodionov.

### 2.1.0 - 2019/03/19

* Add support for specifying Rails test-server port. PR #22 by Bartek Wilczek.

### 2.0.0 - 2016/09/24

* Add support for Watir 6.0.

### 1.2.1 - 2016/06/15

* Fix Browser#add_checker deprecation warning. PR #18 by Christophe Bliard.

### 1.2.0 - 2016/01/16

* Add support for running Rails on Puma server. PR #15 by Andrey Koleshko.

### 1.1.0 - 2015/07/22

* Remove strict `mime-types` dependency. See #13

### 1.0.4 - 2015/02/28

* Allow to set Watir::Rails.ignore_exceptions to false. PR #8 by Andrey Koleshko.

### 1.0.3 - 2013/11/02

* Make watir-rails working with Rails 2.3.x too.

### 1.0.2 - 2013/11/02

* Make sure that newest Rails is going to be installed on an empty system.

### 1.0.1 - 2013/11/01

* Add license to gemspec.

### 1.0.0 - 2013/10/05

* Add watir as a dependency to make it possible to use with watir-classic too.
* Add specs to keep the quality high.
* Documentation fixes.
