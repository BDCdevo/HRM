import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:hrm/features/chat/logic/cubit/chat_cubit.dart';
import 'package:hrm/features/chat/logic/cubit/chat_state.dart';
import 'package:hrm/features/chat/data/repo/chat_repository.dart';
import 'package:hrm/features/chat/data/models/conversation_model.dart';

@GenerateMocks([ChatRepository])
import 'chat_cubit_test.mocks.dart';

void main() {
  late ChatCubit chatCubit;
  late MockChatRepository mockRepository;

  setUp(() {
    mockRepository = MockChatRepository();
    chatCubit = ChatCubit(
      repository: mockRepository,
      companyId: 6,
      currentUserId: 1,
    );
  });

  tearDown(() {
    chatCubit.close();
  });

  group('ChatCubit', () {
    test('initial state is ChatInitial', () {
      expect(chatCubit.state, const ChatInitial());
    });

    test('fetchConversations emits [ChatLoading, ChatLoaded] when successful',
        () async {
      // Arrange
      final mockConversations = [
        const ConversationModel(
          id: 1,
          participantId: 2,
          participantName: 'Ahmed',
          updatedAt: '2025-01-01T10:00:00',
        ),
      ];

      when(mockRepository.getConversations(
        companyId: anyNamed('companyId'),
        currentUserId: anyNamed('currentUserId'),
      )).thenAnswer((_) async => mockConversations);

      // Assert
      expect(
        chatCubit.stream,
        emitsInOrder([
          const ChatLoading(),
          ChatLoaded(mockConversations),
        ]),
      );

      // Act
      await chatCubit.fetchConversations();
    });

    test('fetchConversations emits [ChatLoading, ChatError] when fails',
        () async {
      // Arrange
      when(mockRepository.getConversations(
        companyId: anyNamed('companyId'),
        currentUserId: anyNamed('currentUserId'),
      )).thenThrow(Exception('Network error'));

      // Assert
      expect(
        chatCubit.stream,
        emitsInOrder([
          const ChatLoading(),
          isA<ChatError>(),
        ]),
      );

      // Act
      await chatCubit.fetchConversations();
    });

    test('createConversation emits [ConversationCreating, ConversationCreated] when successful',
        () async {
      // Arrange
      when(mockRepository.createConversation(
        companyId: anyNamed('companyId'),
        userIds: anyNamed('userIds'),
      )).thenAnswer((_) async => 123);

      // Assert
      expect(
        chatCubit.stream,
        emitsInOrder([
          const ConversationCreating(),
          const ConversationCreated(123),
        ]),
      );

      // Act
      await chatCubit.createConversation(userIds: [10]);
    });

    test('reset sets state back to ChatInitial', () {
      // Act
      chatCubit.reset();

      // Assert
      expect(chatCubit.state, const ChatInitial());
    });
  });
}
