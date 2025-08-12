const supabase = require('../config/supabase');

class User {
  constructor(data) {
    this.id = data.id;
    this.email = data.email;
    this.role = data.role; // 'patient' 또는 'caregiver'
    this.name = data.name;
    this.phone = data.phone;
    this.created_at = data.created_at;
    this.updated_at = data.updated_at;
  }

  // 사용자 생성
  static async create(userData) {
    try {
      const { data, error } = await supabase
        .from('users')
        .insert([userData])
        .select()
        .single();

      if (error) throw error;
      return new User(data);
    } catch (error) {
      throw error;
    }
  }

  // 이메일로 사용자 찾기
  static async findByEmail(email) {
    try {
      const { data, error } = await supabase
        .from('users')
        .select('*')
        .eq('email', email)
        .single();

      if (error) throw error;
      return data ? new User(data) : null;
    } catch (error) {
      throw error;
    }
  }

  // ID로 사용자 찾기
  static async findById(id) {
    try {
      const { data, error } = await supabase
        .from('users')
        .select('*')
        .eq('id', id)
        .single();

      if (error) throw error;
      return data ? new User(data) : null;
    } catch (error) {
      throw error;
    }
  }

  // 사용자 정보 업데이트
  async update(updateData) {
    try {
      const { data, error } = await supabase
        .from('users')
        .update(updateData)
        .eq('id', this.id)
        .select()
        .single();

      if (error) throw error;
      Object.assign(this, data);
      return this;
    } catch (error) {
      throw error;
    }
  }

  // 사용자 삭제
  async delete() {
    try {
      const { error } = await supabase
        .from('users')
        .delete()
        .eq('id', this.id);

      if (error) throw error;
      return true;
    } catch (error) {
      throw error;
    }
  }
}

module.exports = User;
