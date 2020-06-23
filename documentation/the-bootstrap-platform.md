# On-Premise Installation

This repository will help you create a local installation of the Caffeine
platform. It is aimed at users who want to try out the platform with their own
proprietary data, but do not want to upload that data to the public platform.

Please note that our public platform does allow for user registration, and any
uploaded data is of course only accessible to its owner. To avoid the hassle of
a local installation, consider simply using the public platform at:
[https://caffeine.dd-decaf.eu](https://caffeine.dd-decaf.eu)

The bootstrap installation behaves mostly like the public platform, but with a
few notable differences described below.

## Authentication:

There is no firebase authentication, which means that you can not log in with
a social account like Google, Twitter or Github. Instead, you need to log in
with one of our predefined user accounts.

Email address: demo0@demo
Password: demo

We have created 40 accounts, so you can replace 0 with any number up to 39 for
the email address: demo[0-39]@demo

## Public models and maps:

The public models and maps on the public platform do not come pre-installed
with the bootstrap installation. Since the platform will be empty when you
visit it for the first time, one of the first things you might want to do is
to upload your own data.