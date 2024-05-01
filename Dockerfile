FROM python:3
RUN pip3 install gunicorn flask boto3 requests
COPY . app/
WORKDIR app/
CMD ["python3", "-m", "gunicorn", "-w 4",  "--bind=0.0.0.0:8000", "weather:app"]