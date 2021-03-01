# frozen_string_literal: true
class KnownNumbersFiltered
  def call(user_phone_number_id:, friend_phone_number_ids:)
    friend_users = User.where(phone_number_id: friend_phone_number_ids)

    if friend_users.blank?
      return <<~SQL
        SELECT id AS phone_number_id FROM phone_numbers WHERE id IN (#{Array.wrap(friend_phone_number_ids).join(',')})
      SQL
    end

    # TODO: here we don't expect one UserContact name to be associated with
    # different Users but its possible
    friend = friend_users.first

    known_users_sql = known_users_filtered(user_phone_number_id: user_phone_number_id, friend_id: friend.id)

    <<~SQL
                  WITH known_users AS (#{known_users_sql})
      #{'      '}
                  SELECT id AS phone_number_id FROM phone_numbers WHERE id IN (#{Array.wrap(friend_phone_number_ids).join(',')})
            #{'      '}
                  UNION
      #{'      '}
                  SELECT phone_number_id
                  FROM user_contacts
                  WHERE user_id = #{friend.id}
                        AND user_contacts.phone_number_id != #{user_phone_number_id}
      #{'      '}
                  UNION
      #{'      '}
                  SELECT DISTINCT phone_number_id
                  FROM user_contacts
                  WHERE user_id IN (SELECT id FROM known_users)
    SQL
  end

  private

  def known_users_filtered(user_phone_number_id:, friend_id:)
    <<~SQL
      WITH RECURSIVE p AS (

        SELECT users.id
        FROM users
        JOIN user_contacts ON user_contacts.phone_number_id = users.phone_number_id
        WHERE user_contacts.user_id = #{friend_id} AND user_contacts.phone_number_id != #{user_phone_number_id}

        UNION

        SELECT new_users.id
        FROM p
        JOIN user_contacts ON user_contacts.user_id = p.id AND user_contacts.phone_number_id != #{user_phone_number_id}
        JOIN users AS new_users ON user_contacts.phone_number_id = new_users.phone_number_id
      )

      SELECT DISTINCT id FROM p
    SQL
  end
end
