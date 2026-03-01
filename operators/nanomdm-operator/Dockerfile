FROM python:3.13-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .

ENTRYPOINT ["kopf", "run", "--liveness=http://0.0.0.0:8081/healthz", "--standalone", "main.py"]
