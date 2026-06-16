#!/bin/bash
# Setup Composer auth for Elementor Pro in DDEV container
# Called by DDEV post-start hook

if [ -z "${ELEMENTOR_PRO_LICENSE:-}" ]; then
  echo "⚠️  ELEMENTOR_PRO_LICENSE not set in .env — Elementor Pro installs will fail"
  exit 0
fi

echo "🔐 Configuring Composer auth for Elementor Pro..."
composer config --auth http-basic.composer.elementor.com token "${ELEMENTOR_PRO_LICENSE}"
echo "✅ Composer auth configured"
