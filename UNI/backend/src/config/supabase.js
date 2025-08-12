const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabaseUrl = process.env.SUPABASE_URL || 'https://gfgctvewtjpcntnhmddk.supabase.co';
const supabaseKey = process.env.SUPABASE_ANON_KEY || 'sb_publishable_oPdCLXcuPtmvhHLLxxx1rw_J7K6GzzO';

console.log('Supabase 설정:', { supabaseUrl, supabaseKey: supabaseKey?.substring(0, 20) + '...' });

const supabase = createClient(supabaseUrl, supabaseKey);

module.exports = supabase;
