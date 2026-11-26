# frozen_string_literal: true

module FastGettext
  # The plural expression of a Plural-Forms header, or the pluralisation_rule
  # of a YAML locale, is arithmetic over n. Parse it here instead of evaluating
  # it: a catalogue is input, and a rule in it must never run as Ruby code.
  #
  # The grammar is the one GNU gettext defines for the expression: decimal
  # integers, the variable n, parentheses, the ternary ?:, comparison, equality,
  # boolean, additive and multiplicative operators, and !, unary - and unary +.
  # Anything else raises InvalidExpression.
  module PluralExpression
    # A rule outside the grammar. It is a SyntaxError because the evaluation
    # this replaces raised SyntaxError for a rule Ruby could not parse.
    class InvalidExpression < SyntaxError; end

    OPERATORS = [
      "||", "&&", "==", "!=", "<=", ">=", "<", ">",
      "+", "-", "*", "/", "%", "!", "?", ":", "(", ")"
    ].freeze
    PRECEDENCE = {
      "||" => 1,
      "&&" => 2,
      "==" => 3, "!=" => 3,
      "<" => 4, "<=" => 4, ">" => 4, ">=" => 4,
      "+" => 5, "-" => 5,
      "*" => 6, "/" => 6, "%" => 6
    }.freeze
    TOKEN = /\s+|#{Regexp.union(OPERATORS)}|\d+|\bn\b|./

    module_function

    # Compile a rule to a callable that selects a plural index for a count.
    def compile(source)
      expression = Parser.new(tokenize(source)).parse
      ->(n) { evaluate(expression, n) }
    end

    def tokenize(source)
      tokens = source.to_s.scan(TOKEN)
      tokens.reject! { |token| token.match?(/\A\s+\z/) }
      tokens.each do |token|
        next if token == "n" || token.match?(/\A\d+\z/) || OPERATORS.include?(token)

        raise InvalidExpression, "unexpected #{token.inspect} in plural expression"
      end
      tokens
    end

    def evaluate(expression, n)
      case expression[0]
      when :number
        expression[1]
      when :variable
        n
      when :not
        !evaluate(expression[1], n)
      when :negate
        -evaluate(expression[1], n)
      when :positive
        evaluate(expression[1], n)
      when :conditional
        evaluate(expression[1], n) ? evaluate(expression[2], n) : evaluate(expression[3], n)
      else
        operator = expression[1]
        left = evaluate(expression[2], n)
        return left && evaluate(expression[3], n) if operator == "&&"
        return left || evaluate(expression[3], n) if operator == "||"

        right = evaluate(expression[3], n)
        case operator
        when "==" then left == right
        when "!=" then left != right
        when "<" then left < right
        when "<=" then left <= right
        when ">" then left > right
        when ">=" then left >= right
        else left.send(operator, right)
        end
      end
    end

    class Parser
      def initialize(tokens)
        @tokens = tokens
        @position = 0
      end

      def parse
        result = parse_expression
        unless @position == @tokens.size
          raise InvalidExpression, "unexpected #{peek.inspect} in plural expression"
        end

        result
      end

      def parse_expression
        condition = binary(1)
        return condition unless take("?")

        positive = parse_expression
        need(":")
        [:conditional, condition, positive, parse_expression]
      end

      def binary(level)
        return unary if level > 6

        left = binary(level + 1)
        while PRECEDENCE[peek] == level
          operator = peek
          @position += 1
          left = [:binary, operator, left, binary(level + 1)]
        end
        left
      end

      def unary
        return [:not, unary] if take("!")
        return [:negate, unary] if take("-")
        return [:positive, unary] if take("+")

        atom
      end

      def atom
        token = peek
        @position += 1
        case token
        when /\A\d+\z/ then [:number, token.to_i]
        when "n" then [:variable]
        when "(" then parse_expression.tap { need(")") }
        else raise InvalidExpression, "unexpected #{token.inspect} in plural expression"
        end
      end

      def peek
        @tokens[@position]
      end

      def take(token)
        return false unless peek == token

        @position += 1
        true
      end

      def need(token)
        return if take(token)

        raise InvalidExpression, "expected #{token.inspect} in plural expression"
      end
    end
  end
end
