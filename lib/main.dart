import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_community/blocs/auth/auth_bloc.dart';
import 'package:flutter_community/blocs/chat/chat_cubit.dart';
import 'package:flutter_community/blocs/chatroom/chat_room_cubit.dart';
import 'package:flutter_community/blocs/comment/add/comment_add_cubit.dart';
import 'package:flutter_community/blocs/comment/update/comment_update_cubit.dart';
import 'package:flutter_community/blocs/follow/follow_cubit.dart';
import 'package:flutter_community/blocs/pagination/pagination_cubit.dart';
import 'package:flutter_community/blocs/paragraph/add/paragraph_add_cubit.dart';
import 'package:flutter_community/blocs/paragraph/update/paragraph_update_cubit.dart';
import 'package:flutter_community/blocs/profile/profile_cubit.dart';
import 'package:flutter_community/blocs/short/add/short_video_add_cubit.dart';
import 'package:flutter_community/blocs/short/thumbnail/short_thumbnail_cubit.dart';
import 'package:flutter_community/blocs/signin/signin_cubit.dart';
import 'package:flutter_community/blocs/signup/signup_cubit.dart';
import 'package:flutter_community/blocs/upload/upload_cubit.dart';
import 'package:flutter_community/blocs/user/user_cubit.dart';
import 'package:flutter_community/consts/firebase_const.dart';
import 'package:flutter_community/models/chat/chat_room_model.dart';
import 'package:flutter_community/models/comment/comment_model.dart';
import 'package:flutter_community/models/follow/follow_model.dart';
import 'package:flutter_community/models/short_video/short_video_model.dart';
import 'package:flutter_community/pages/auth/signup_page.dart';
import 'package:flutter_community/pages/chat/chat_page.dart';
import 'package:flutter_community/pages/follow/follow_page.dart';
import 'package:flutter_community/pages/main_page.dart';
import 'package:flutter_community/pages/post/paragraph_detail_page.dart';
import 'package:flutter_community/pages/post/posting_page.dart';
import 'package:flutter_community/pages/profile/profile_page.dart';
import 'package:flutter_community/pages/profile/profile_update_page.dart';
import 'package:flutter_community/pages/short/short_video_detail_page.dart';
import 'package:flutter_community/pages/short/short_video_upload_page.dart';
import 'package:flutter_community/pages/auth/signin_page.dart';
import 'package:flutter_community/pages/splash_page.dart';
import 'package:flutter_community/repositories/auth_repository.dart';
import 'package:flutter_community/repositories/chat_repository.dart';
import 'package:flutter_community/repositories/follow_repository.dart';
import 'package:flutter_community/repositories/like_repository.dart';
import 'package:flutter_community/repositories/comment_repository.dart';
import 'package:flutter_community/repositories/paragraph_of_user_repository.dart';
import 'package:flutter_community/repositories/paragraph_repository.dart';
import 'package:flutter_community/repositories/short_video_of_user_repository.dart';
import 'package:flutter_community/repositories/short_video_repository.dart';
import 'package:flutter_community/repositories/user_repository.dart';
import 'package:flutter_community/services/pagination_api_services.dart';
import 'package:flutter_community/services/paragraph_api_services.dart';
import 'package:flutter_community/services/short_video_api_serivces.dart';
import 'package:flutter_community/services/user_api_services.dart';

import 'firebase_options.dart';
import 'models/community/paragraph_model.dart';
import 'models/user/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
            create: (context) => AuthRepository(
                firebaseAuth: FirebaseAuth.instance,
                firestore: FirebaseFirestore.instance)),
        RepositoryProvider<UserRepository>(
            create: (context) => UserRepository(
                firestore: FirebaseFirestore.instance,
                userApiServices: UserApiServices(
                    firestore: FirebaseFirestore.instance,
                    storage: FirebaseStorage.instance))),
        RepositoryProvider<ParagraphRepository>(
            create: (context) => ParagraphRepository(
                paginationApiServices: PaginationApiServices<ParagraphModel,
                        CollectionReference<Map<String, dynamic>>>(
                    firestore: FirebaseFirestore.instance,
                    collectionRef: paragraphsRef,
                    paginationType: PaginationType.paragraph),
                paragraphApiServices: ParagraphApiServices(
                    firestore: FirebaseFirestore.instance,
                    storage: FirebaseStorage.instance))),
        RepositoryProvider<CommentRepository>(
            create: (context) => CommentRepository(
                firestore: FirebaseFirestore.instance,
                paginationApiServices: PaginationApiServices<CommentModel,
                        CollectionReference<Map<String, dynamic>>>(
                    firestore: FirebaseFirestore.instance,
                    collectionRef: commentsRef,
                    paginationType: PaginationType.comment))),
        RepositoryProvider<LikeRepository>(
            create: (context) =>
                LikeRepository(firestore: FirebaseFirestore.instance)),
        RepositoryProvider<FollowRepository>(
            create: (context) => FollowRepository(
                firestore: FirebaseFirestore.instance,
                apiServices: PaginationApiServices<FollowModel,
                        CollectionReference<Map<String, dynamic>>>(
                    firestore: FirebaseFirestore.instance,
                    collectionRef: followsRef,
                    paginationType: PaginationType.comment))),
        RepositoryProvider<ParagraphOfUserRepository>(
            create: (context) => ParagraphOfUserRepository(
                apiServices: PaginationApiServices(
                    collectionRef: paragraphsRef,
                    paginationType: PaginationType.paragraph,
                    firestore: FirebaseFirestore.instance))),
        RepositoryProvider<ChatRepository>(
            create: (context) => ChatRepository(
                firestore: FirebaseFirestore.instance,
                storage: FirebaseStorage.instance)),
        RepositoryProvider<ShortVideoRepository>(
            create: (context) => ShortVideoRepository(
                shortVideoApiServices: ShortVideoApiServices(
                    firestore: FirebaseFirestore.instance,
                    storage: FirebaseStorage.instance),
                paginationApiServices: PaginationApiServices<ShortVideoModel,
                        CollectionReference<Map<String, dynamic>>>(
                    firestore: FirebaseFirestore.instance,
                    collectionRef: shortVideosRef,
                    paginationType: PaginationType.paragraph))),
        RepositoryProvider<ShortVideoOfUserRepository>(
            create: (context) => ShortVideoOfUserRepository(
                shortVideoApiServices: ShortVideoApiServices(
                    firestore: FirebaseFirestore.instance,
                    storage: FirebaseStorage.instance),
                paginationApiServices: PaginationApiServices<ShortVideoModel,
                    CollectionReference<Map<String, dynamic>>>(
                    firestore: FirebaseFirestore.instance,
                    collectionRef: shortVideosRef,
                    paginationType: PaginationType.paragraph)))
      ],
      child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(
                create: (context) =>
                    AuthBloc(repository: context.read<AuthRepository>())),
            BlocProvider<SigninCubit>(
                create: (context) =>
                    SigninCubit(repository: context.read<AuthRepository>())),
            BlocProvider<SignupCubit>(
                create: (context) =>
                    SignupCubit(repository: context.read<AuthRepository>())),
            BlocProvider<ProfileCubit>(
                create: (context) => ProfileCubit(
                    authRepository: context.read<AuthRepository>(),
                    repository: context.read<UserRepository>())),
            BlocProvider<ParagraphAddCubit>(
                create: (context) => ParagraphAddCubit(
                    repository: context.read<ParagraphRepository>())),
            BlocProvider<PaginationCubit<ParagraphModel, ParagraphRepository>>(
                create: (context) =>
                    PaginationCubit<ParagraphModel, ParagraphRepository>(
                        repository: context.read<ParagraphRepository>(),
                        followRepository: context.read<FollowRepository>())),
            BlocProvider<PaginationCubit<CommentModel, CommentRepository>>(
                create: (context) =>
                    PaginationCubit<CommentModel, CommentRepository>(
                        repository: context.read<CommentRepository>(),
                        followRepository: context.read<FollowRepository>())),
            BlocProvider<PaginationCubit<UserModel, FollowRepository>>(
                create: (context) =>
                    PaginationCubit<UserModel, FollowRepository>(
                        repository: context.read<FollowRepository>(),
                        followRepository: context.read<FollowRepository>())),
            BlocProvider<
                    PaginationCubit<ParagraphModel, ParagraphOfUserRepository>>(
                create: (context) =>
                    PaginationCubit<ParagraphModel, ParagraphOfUserRepository>(
                        repository: context.read<ParagraphOfUserRepository>(),
                        followRepository: context.read<FollowRepository>())),
            BlocProvider<
                    PaginationCubit<ShortVideoModel, ShortVideoRepository>>(
                create: (context) =>
                    PaginationCubit<ShortVideoModel, ShortVideoRepository>(
                        repository: context.read<ShortVideoRepository>(),
                        followRepository: context.read<FollowRepository>())),
            BlocProvider<CommentAddCubit>(
                create: (context) => CommentAddCubit(
                    repository: context.read<CommentRepository>())),
            BlocProvider<ParagraphUpdateCubit>(
                create: (context) => ParagraphUpdateCubit(
                    repository: context.read<ParagraphRepository>())),
            BlocProvider<CommentUpdateCubit>(
                create: (context) => CommentUpdateCubit(
                    repository: context.read<CommentRepository>())),
            BlocProvider<UserCubit>(
                create: (context) =>
                    UserCubit(repository: context.read<UserRepository>())),
            BlocProvider<FollowCubit>(
                create: (context) => FollowCubit(
                    repository: context.read<FollowRepository>(),
                    profileCubit: context.read<ProfileCubit>(),
                    followPaginationCubit: context
                        .read<PaginationCubit<UserModel, FollowRepository>>())),
            BlocProvider<ChatCubit>(
                create: (context) => ChatCubit(
                    chatRepository: context.read<ChatRepository>(),
                    profileCubit: context.read<ProfileCubit>(),
                    userRepository: context.read<UserRepository>())),
            BlocProvider<ChatRoomCubit>(
                create: (context) =>
                    ChatRoomCubit(repository: context.read<ChatRepository>())),
            BlocProvider<UploadCubit>(
                create: (context) =>
                    UploadCubit(repository: context.read<ChatRepository>())),
            BlocProvider<ShortVideoAddCubit>(
                create: (context) => ShortVideoAddCubit(
                    repository: context.read<ShortVideoRepository>())),
            BlocProvider<ShortThumbnailCubit>(
                create: (context) => ShortThumbnailCubit(
                    shortPaginationCubit: context.read<
                        PaginationCubit<ShortVideoModel,
                            ShortVideoRepository>>())),
            BlocProvider<ShortThumbnailCubit>(
                create: (context) => ShortThumbnailCubit(
                    shortPaginationCubit: context.read<
                        PaginationCubit<ShortVideoModel,
                            ShortVideoRepository>>()))
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "Flutter Community",
            routes: {
              SplashPage.routeName: (context) => SplashPage(),
              SigninPage.routeName: (context) => SigninPage(),
              SignupPage.routeName: (context) => SignupPage(),
              MainPage.routeName: (context) => MainPage(),
              PostingPage.routeName: (context) => PostingPage(),
              ProfileUpdatePage.routeName: (context) => ProfileUpdatePage(),
              FollowPage.routeName: (context) => FollowPage(),
              ShortVideoUploadPage.routeName: (context) =>
                  ShortVideoUploadPage()
            },
            onGenerateRoute: (RouteSettings settings) {
              if (settings.name == ProfilePage.routeName) {
                return MaterialPageRoute(
                    builder: (context) =>
                        ProfilePage(uid: settings.arguments as String));
              } else if (settings.name == ParagraphDetailPage.routeName) {
                return MaterialPageRoute(
                    builder: (context) => ParagraphDetailPage(
                        paragraphModel: settings.arguments as ParagraphModel));
              } else if (settings.name == ChatPage.routeName) {
                return MaterialPageRoute(
                    builder: (context) => ChatPage(
                        chatRoom: settings.arguments as ChatRoomModel));
              } else if (settings.name == ShortVideoDetailPage.routeName) {
                return MaterialPageRoute(
                    builder: (context) =>
                        ShortVideoDetailPage(id: settings.arguments as String));
              }
            },
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
          )),
    );
  }
}
