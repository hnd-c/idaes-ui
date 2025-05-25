# Use Python 3.10 as base image (3.11 has compatibility issues)
FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Install system dependencies including Node.js
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    wget \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV NODE_ENV=development

# Copy package files first for better caching
COPY package*.json /app/
COPY pyproject.toml /app/
COPY requirements-dev.txt /app/

# Install Node.js dependencies
RUN npm install

# Install Python dependencies
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Copy the entire IDAES-UI source
COPY . /app/idaes-ui/

# Install Pyomo and other dependencies that IDAES-UI needs
RUN pip install \
    pyomo \
    numpy \
    pandas \
    matplotlib \
    plotly \
    bokeh \
    scipy \
    networkx

# Install IDAES-PSE first (required for extensions)
RUN pip install idaes-pse

# Install IDAES-UI in development mode
WORKDIR /app/idaes-ui
RUN pip install -e .[testing]

# Install IDAES extensions using the standard method
RUN idaes get-extensions --distro ubuntu2204 --verbose

# Add IDAES bin directory to PATH permanently
ENV PATH="/root/.idaes/bin:$PATH"

# Install playwright and browsers
RUN pip install playwright==1.42.0 && playwright install --with-deps

# Install additional dependencies for web development
RUN pip install \
    flask \
    flask-cors \
    fastapi \
    uvicorn \
    websockets \
    watchdog

# Set working directory back to app
WORKDIR /app

# Expose port
EXPOSE 49999

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:49999 || exit 1

# Default command
CMD ["python", "-m", "idaes_ui.fv.example"]