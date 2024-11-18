FROM python:3.9

# Set environment variables
ENV JWT_SECRET_KEY="QYmXTKt6bnzaFi76H7R88FQ"
ENV AUTH_SECRET_KEY="django-insecure-zv-czil2aib8@ex@n+k#nh62r-p3r4t3dufvc4at=w"
ENV MYSQL_DATABASE="authentication_db"
ENV MYSQL_USER="root"
ENV MYSQL_PASSWORD="obdif"
ENV MYSQL_HOST="auth-service-mysql"

RUN apt update && apt install -y gcc libmariadb-dev-compat

# Install gunicorn and other dependencies
WORKDIR /app
COPY requirements.txt /app/requirements.txt
RUN pip install -r requirements.txt

# Create a non-root user
RUN useradd -m nonroot
USER nonroot

# Copy the application code
COPY . /app

# Expose the port that the app runs on
EXPOSE 8080

# Use a script to wait for the database to be ready before running migrations
CMD ["sh", "-c", "until nc -z auth-service-mysql 3306; do echo 'Waiting for MySQL...'; sleep 5; done; python manage.py migrate; gunicorn -w 4 -b 0.0.0.0:8080 admin.wsgi"]
