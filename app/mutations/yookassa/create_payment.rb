class CreatePayment < Mutations::Command
  required do     
    integer :value
    string :description
    string :platform_id
    string :email
    integer :quantity_points

  end

  
  def execute 
    payment = Yookassa.payments.create(payment: create_pay_data)
  end


  def create_pay_data
    {
      amount: {
          value: inputs[:value],
          currency: 'RUB'
      },
      capture:      true,
      confirmation: {
          type:       'redirect',
          return_url: 'https://t.me/infobizaa_bot'
      },
      receipt: {
        customer: {
          email: inputs[:email]
        },
        items: [
          {
            "description": inputs[:description],
            "quantity": "1",
            "amount": {
              "value": inputs[:value],
              "currency": "RUB"
            },
            "vat_code": "1"
          }
        ]
      },
      metadata: {
        platform_id: inputs[:platform_id],
        email: inputs[:email],
        quantity_points: inputs[:quantity_points]
      }
    }
  end
end