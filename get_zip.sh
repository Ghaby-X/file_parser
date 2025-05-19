#!/bin/bash

cd function && zip lambda_function_payload.zip lambda_function.py
mv lambda_function_payload.zip ../infrastructure/lambda_function_payload.zip
