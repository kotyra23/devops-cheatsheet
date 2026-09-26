# ЭТАП 1: Сборка зависимостей (Builder)
FROM python:3.11-slim as builder

WORKDIR /app

COPY app/requirements.txt .

RUN pip install --no-cache-dir --user -r requirements.txt


# ЭТАП 2: Финальный легкий образ (Runner)
FROM python:3.11-slim

WORKDIR /app

# BEST PRACTICE: Создаем не-root пользователя для запуска приложения
RUN useradd -m -u 1000 appuser

# Копируем установленные пакеты из этапа builder
COPY --from=builder /root/.local /home/appuser/.local

# Копируем исходный код приложения
COPY app/ ./app/

# Настраиваем переменные окружения
ENV PATH=/home/appuser/.local/bin:$PATH
ENV FLASK_APP=app/app.py
ENV FLASK_RUN_HOST=0.0.0.0

# Важно: заставляет Python писать логи сразу в stdout, а не буферизировать
ENV PYTHONUNBUFFERED=1

# Переключаемся на не-root пользователя
USER appuser

# Открываем порт
EXPOSE 5000

# Команда запуска
CMD ["python", "-m", "flask", "run"]
