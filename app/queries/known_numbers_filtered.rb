# frozen_string_literal: true
class KnownNumbersFiltered
  def call(user_id, max_hands_count: UserFriendlyAdsQuery::MAX_HANDS_COUNT, filtered_friends_phone_number_ids: [])
    <<~SQL
      WITH RECURSIVE p AS (
        SELECT id AS phone_number_id, 1 AS idx FROM phone_numbers WHERE id IN (#{filtered_friends_phone_number_ids.join(',')})

        UNION

        SELECT friends.phone_number_id, (p.idx + 1) AS idx
        FROM user_contacts AS friends
        JOIN users ON friends.user_id = users.id AND users.phone_number_id IN (#{filtered_friends_phone_number_ids.join(',')})
        JOIN p ON users.phone_number_id = p.phone_number_id AND users.id != #{user_id}
        WHERE p.idx < #{max_hands_count}
      )

      SELECT DISTINCT phone_number_id FROM p
    SQL
  end
end
