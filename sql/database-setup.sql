-- Script de configuración integral para Supabase
-- TABLA: usuarios (la gestiona Supabase Auth)
-- TABLA: expense_types (Tipos de gasto)
CREATE TABLE IF NOT EXISTS expense_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);
ALTER TABLE expense_types ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow individual read access" ON expense_types FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Allow individual insert access" ON expense_types FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Allow individual update access" ON expense_types FOR UPDATE USING (user_id = auth.uid());
CREATE POLICY "Allow individual delete access" ON expense_types FOR DELETE USING (user_id = auth.uid());
CREATE INDEX idx_expense_types_user_id ON expense_types(user_id);

-- TABLA: payment_methods (Métodos de pago)
CREATE TABLE IF NOT EXISTS payment_methods (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  type TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);
ALTER TABLE payment_methods ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow individual read access" ON payment_methods FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Allow individual insert access" ON payment_methods FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Allow individual update access" ON payment_methods FOR UPDATE USING (user_id = auth.uid());
CREATE POLICY "Allow individual delete access" ON payment_methods FOR DELETE USING (user_id = auth.uid());
CREATE INDEX idx_payment_methods_user_id ON payment_methods(user_id);

-- TABLA: expense_templates (Plantillas de gastos)
CREATE TABLE IF NOT EXISTS expense_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  items JSONB NOT NULL DEFAULT '[]', -- Arreglo de objetos: [{description, amount, expense_type_id, ...}]
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);
ALTER TABLE expense_templates ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow individual read access" ON expense_templates FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Allow individual insert access" ON expense_templates FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Allow individual update access" ON expense_templates FOR UPDATE USING (user_id = auth.uid());
CREATE POLICY "Allow individual delete access" ON expense_templates FOR DELETE USING (user_id = auth.uid());
CREATE INDEX idx_expense_templates_user_id ON expense_templates(user_id);

-- TABLA: monthly_expenses (Registros mensuales)
CREATE TABLE IF NOT EXISTS monthly_expenses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  period VARCHAR(7) NOT NULL, -- 'YYYY-MM' (Mes)
  template_id UUID REFERENCES expense_templates(id) ON DELETE SET NULL,
  expenses JSONB NOT NULL DEFAULT '[]', -- Arreglo de gastos para el mes (detalle)
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);
ALTER TABLE monthly_expenses ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow individual read access" ON monthly_expenses FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Allow individual insert access" ON monthly_expenses FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Allow individual update access" ON monthly_expenses FOR UPDATE USING (user_id = auth.uid());
CREATE POLICY "Allow individual delete access" ON monthly_expenses FOR DELETE USING (user_id = auth.uid());
CREATE INDEX idx_monthly_expenses_user_id ON monthly_expenses(user_id);
CREATE INDEX idx_monthly_expenses_period ON monthly_expenses(period);

-- Tabla de gastos principal (expenses) ya existe en otro script (create_expenses_table.sql)
-- Se recomienda ejecutar ambos scripts! Si se requiere incluirlo aquí, copiar su contenido debajo de este bloque.

-- Script para crear la tabla expenses
CREATE TABLE IF NOT EXISTS expenses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  description TEXT NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  expense_type_id UUID REFERENCES expense_types(id) ON DELETE SET NULL,
  payment_method_id UUID REFERENCES payment_methods(id) ON DELETE SET NULL,
  date DATE NOT NULL,
  is_recurring BOOLEAN DEFAULT FALSE,
  template_id UUID REFERENCES expense_templates(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Habilitar RLS para la tabla expenses
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;

-- Políticas de seguridad
CREATE POLICY "Allow individual read access" ON expenses
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Allow individual insert access" ON expenses
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Allow individual update access" ON expenses
  FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "Allow individual delete access" ON expenses
  FOR DELETE USING (user_id = auth.uid());

-- Índices para mejorar el rendimiento
CREATE INDEX idx_expenses_user_id ON expenses(user_id);
CREATE INDEX idx_expenses_date ON expenses(date);
CREATE INDEX idx_expenses_template_id ON expenses(template_id);

-- Configuración adicional
-- Habilitar la extensión pgcrypto si no está habilitada (usada para gen_random_uuid)
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
-- Habilitar la extensión para timestamps (opcional en supabase)
// ... existing code ...