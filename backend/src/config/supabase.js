const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabaseUrl = process.env.SUPABASE_URL || 'https://yfimuntjanrhhsxogmnw.supabase.co';
const supabaseKey = process.env.SUPABASE_ANON_KEY || 'sb_publishable_lYdNwinXWuWC_Z6iUXm2Mg_FOYoLnRq';

console.log('✅ Supabase 설정:', { 
  supabaseUrl, 
  supabaseKey: supabaseKey?.substring(0, 20) + '...' 
});

const supabase = createClient(supabaseUrl, supabaseKey);

module.exports = supabase;
