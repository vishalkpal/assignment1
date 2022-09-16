# assignment1

Terraform - Write a terraform code which will create a S3 Bucket, create a Cloudfront distribution and upload a simple "index.html" to the bucket. Output to the terraform code should be the cloudfront distribution URL and on hitting the URL, "index.html" should be served.

Time --> 4-5 hours

Steps:
At first my script will create a s3 bucket .
Then it will upload a index.html file to s3.
Then it will create our cloudfront distribution which will host our index.html.


Security measures
I have kept the bucket and objects as private.
only cloudfront haveaccess to bucket using oicd.
