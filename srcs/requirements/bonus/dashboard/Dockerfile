FROM		debian:bullseye

RUN			apt-get update -y && \
			apt-get install -y python3 && \
			rm -rf /var/lib/apt/lists/*

COPY		./tools/dashboard.py /app/dashboard.py
COPY		./tools/dashboard.html /app/dashboard.html
COPY		./tools/style.css /app/style.css

EXPOSE		8082

ENTRYPOINT	[ "python3", "/app/dashboard.py" ]
