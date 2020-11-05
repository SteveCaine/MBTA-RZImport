MBTA-RZImport
=============

***NOTE:*** *The MBTA has discontinued this API and replaced it with a JSON service that this project does not implement. Thus this project remains useful only in demonstrating how to parse the JSON and XML responses this service used to return, and how to structure code to make and receive the calls the past service provided. (updated Nov. 5, 2020)*

This repository contains code that demonstrates how to access the Boston MBTA's *former* [RESTful web service](http://www.mbta.com/rider_tools/developers/) for information about the public transit agency's routes and services.

It uses the open-source [RZImport](https://github.com/Raizlabs/RZImport) library to access the public API *that was* provided by version 2 of the MBTA-realtime RSS web service. The included demo app uses this library to execute the first five of the 20-plus queries provided by the MBTA service. 

This demo app offers two options: 

* Direct 'get' methods that always make fresh requests of the web service.

* Matching 'request' methods that (except for time-sensitive requests) cache previous responses and use this cache to fulfill later requests (up until a 'staleAge' specific to each request type).

In addition to RZImport, the app uses code adapted from the open-source [XML-to-NSDictionary](https://github.com/blakewatters/XML-to-NSDictionary) library to support parsing responses delivered as XML rather than JSON (when the compile-time flag 'CONFIG_useXML' is set in file "MBTA-RZImport-Prefix.pch"). And it uses [AFNetworking](http://afnetworking.com) to connect with the MBTA web service. 

All of this third-party code, except that for XML, is managed by [CocoaPods](http://cocoapods.org).

And it uses my [DebugUtil](https://github.com/SteveCaine/DebugUtil) code (also on GitHub) to provide debug-build logging that falls silent in release builds. This requires both repositories be cloned to the same folder on the developer's Mac. To simplify this, my [unix-scripts](https://github.com/SteveCaine/unix-scripts) repository includes a 'cloneall' script to download all my public repositories to the current folder; the script contains detailed instructions on its use. 

All raw XML or JSON responses from the MBTA can be written to NSLog() by setting the compile-time flag 'DEBUG_logRawResponse' in "MBTA-RZImport-Prefix.pch".

**To use this code**, launch the app and tap any of the five rows in the two sections of the table presented. Each will execute a separate API call and display a brief summary of the response in the table cell. Detailed information about the response is written to the Xcode debugger's console. 

Rows in the first section -- "**get data (no caching)**" -- make direct calls to the API to either create new objects for that request (the first time that row is tapped) or update existing objects with a repeat of the same request (on each successive tap).

Rows in the second section -- "**request data (with caching)**" create a 'request' object that is responsible for making the request and holding the response data. This pattern allows the request object to look for JSON/XML files saved from previous requests and use those in place of a new request if the file is younger than a 'stale age' specified by each request class.

**NOTE** 

This code uses the public API key that the MBTA has provided for developers to test their code. For any extended use of the MBTA v2 API, you should obtain your own API key. The public key may be discontinued at any time (especially likely if its use is abused).

Personal API keys are available free of charge from the MBTA's [Developer Portal](http://realtime.mbta.com/portal), one for each app that you develop.  

This code is structured in such a way that other APIs, to access this or other web services, can be added to the app without changing the public interface this code offers to developers. 

It is intended for demonstration purposes only, to show how differing implementations can be combined in a single app while hiding implementation details from the rest of the code. 

Three intentional '#warning' messages remain in this code: 1) that the test API key should not be used in a shipping app, 2) that a class method on *ApiStop* needs updating whenever a new subclass is created, and 3) that the code to match API requests with cached response files by name will need to change as more API requests are implemented.

This code is distributed under the terms of the MIT license. See file "LICENSE" in this repository for details.

Copyright (c) 2014-2015 Steve Caine.<br>
@SteveCaine on github.com
