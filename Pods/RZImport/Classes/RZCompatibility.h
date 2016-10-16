//
//  RZCompatibility.h
//  RZImport
//
//  Created by John Watson on 8/20/15.
//
//  Copyright 2015 Raizlabs and other contributors
//  http://raizlabs.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


//
// Nullability annotation compatibility.
//

#if __has_feature(nullability)
#   define RZNonnull    nonnull
#   define RZNullable   nullable
#   define RZCNonnull   __nonnull
#   define RZCNullable  __nullable
#else
#   define RZNonnull
#   define RZNullable
#   define RZCNonnull
#   define RZCNullable
#endif

//
// Lightweight generics compatibility.
//

#if __has_feature(objc_generics)
#   define RZGeneric(class, ...) class<__VA_ARGS__>
#   define RZGenericType(type) type
#else
#   define RZGeneric(class, ...) class
#   define RZGenericType(type) id
#endif


#define RZIKeyMap RZGeneric(NSDictionary, NSString *, NSString *)
#define RZIStringDict RZGeneric(NSDictionary, NSString *, id)
#define RZIArrayOfStringDict RZGeneric(NSArray, RZIStringDict *)
#define RZIStringArray RZGeneric(NSArray, NSString *)
